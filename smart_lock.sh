#!/bin/bash

# Smart Account Lock/Unlock System
# Author: Saurabh Kumar Ranjan
# Description: Automatically locks accounts after 5 failed login attempts within 1 minute,
# and unlocks them after 1 hour of inactivity.

# Log file paths
AUTH_LOG="/var/log/auth.log"  
FAILED_LOG="/tmp/failed_login_attempts.log"
LOCKED_USERS="/tmp/locked_users.log"

# Configuration
MAX_ATTEMPTS=5
TIME_WINDOW=60  # Time window in seconds (1 minute)
UNLOCK_DELAY=3600  # Unlock delay in seconds (1 hour)

# Function to monitor and lock accounts
monitor_logins() {
    echo "Monitoring failed login attempts..."

    # Analyze the auth log for failed login attempts within the last TIME_WINDOW seconds
    awk -v now="$(date +%s)" -v time_window=$TIME_WINDOW '
    /Failed password/ {
        match($0, /for ([a-zA-Z0-9_]+)/, user);
        if (user[1] && $0 ~ /from/) {
            time = mktime(gensub(/[-:]/, " ", "g", $1 " " $2 " " $3));
            if (now - time <= time_window) {
                print user[1];
            }
        }
    }' "$AUTH_LOG" | sort | uniq -c | awk -v max_attempts=$MAX_ATTEMPTS '$1 >= max_attempts {print $2}' > "$FAILED_LOG"

    # Lock the accounts that exceeded the MAX_ATTEMPTS
    while read -r user; do
        if id "$user" &>/dev/null; then
            sudo usermod -L "$user"  # Lock the user account
            echo "Locked account: $user" | tee -a "$LOCKED_USERS"
        fi
    done < "$FAILED_LOG"
}

# Function to unlock accounts after UNLOCK_DELAY
unlock_accounts() {
    echo "Unlocking accounts after inactivity..."

    while read -r user timestamp; do
        if [[ $(($(date +%s) - timestamp)) -ge $UNLOCK_DELAY ]]; then
            sudo usermod -U "$user"  # Unlock the user account
            echo "Unlocked account: $user"
            sed -i "/^$user /d" "$LOCKED_USERS"  # Remove the user from the locked users list
        fi
    done < <(awk '{print $1, $2}' "$LOCKED_USERS")
}

# Function to set up automation using cron
setup_cron() {
    echo "Setting up cron jobs for automation..."
    CRON_FILE="/tmp/smart_lock_cron"

    # Create cron jobs for monitoring and unlocking
    cat <<EOF >"$CRON_FILE"
* * * * * $(realpath "$0") monitor
*/5 * * * * $(realpath "$0") unlock
EOF

    crontab "$CRON_FILE"
    echo "Cron jobs installed."
}

# Main function
main() {
    case $1 in
    monitor)
        monitor_logins
        ;;
    unlock)
        unlock_accounts
        ;;
    setup)
        setup_cron
        ;;
    *)
        echo "Usage: $0 {monitor|unlock|setup}"
        exit 1
        ;;
    esac
}

main "$@"
