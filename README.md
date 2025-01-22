# 🔐 Smart Account Lock/Unlock System

## 📝 Description
The **Smart Account Lock/Unlock System** is a shell script-based project designed to enhance system security by automating user account management. This script monitors failed login attempts in real-time, dynamically locks user accounts after a set threshold, and automatically unlocks them after a predefined period of inactivity. It is a practical solution for reducing administrative overhead while addressing security challenges in Linux-based systems.

This project demonstrates the power of shell scripting, log file analysis, and process automation to solve real-world problems in system administration.

---

## ⚙️ Features
1. **Dynamic Account Locking**  
   - Monitors login attempts and automatically locks a user account after exceeding the maximum failed attempts threshold (default: 5 attempts) within a specific time window (default: 1 minute).  
   - Protects against unauthorized access attempts.

2. **Automatic Unlocking**  
   - Automatically unlocks locked accounts after a period of inactivity (default: 1 hour), removing the need for manual intervention by system administrators.  

3. **Log Integration**  
   - Analyzes authentication logs (`/var/log/auth.log`) in real-time using `awk` and other Linux utilities to track failed login attempts.  

4. **End-to-End Automation**  
   - Automates monitoring and unlocking processes using `cron` jobs, ensuring efficiency and reliability.  

5. **Customizable**  
   - Easily modify thresholds for failed attempts, time window, and unlock delay to suit your requirements.  

---

## 🎯 Project Outcomes
This system enhances Linux server security by:  
- Preventing brute force attacks and unauthorized access.  
- Automating account management to reduce administrative workload.  
- Providing a reusable, modular script for managing login security.

---

## 🛠️ Requirements
- A Linux-based system (tested on Debian/Ubuntu).  
- Root privileges (`sudo`) to lock/unlock accounts.  
- Basic familiarity with shell scripting and system logs.

---

## 🚀 How It Works

1. **Monitor Logins**  
   - The script parses the system authentication log (`/var/log/auth.log`) for failed login attempts.  
   - If a user exceeds the maximum number of failed attempts within the specified time window, their account is locked.  

2. **Account Locking**  
   - User accounts are locked dynamically using the `usermod -L` command.  
   - Locked accounts are logged for future processing in `/tmp/locked_users.log`.  

3. **Account Unlocking**  
   - The script periodically checks the locked accounts log.  
   - Accounts that remain locked for longer than the specified inactivity period are unlocked automatically using the `usermod -U` command.  

4. **Cron Automation**  
   - The script schedules two cron jobs:
     - **Monitoring Cron Job**: Runs every minute to check for failed login attempts.  
     - **Unlocking Cron Job**: Runs every 5 minutes to unlock inactive accounts.  

---

## 📂 File Structure
- `smart_lock.sh` — The main shell script that handles monitoring, locking, and unlocking of accounts.  
- `/tmp/failed_login_attempts.log` — Temporary log file for tracking failed login attempts.  
- `/tmp/locked_users.log` — Log file that records locked accounts and their lock timestamps.  

---

## 🖥️ Usage

### 1. Clone the Repository
```bash
git clone https://github.com/skranjan1999/Smart-account-lock-unlock-system.git
cd smart-account-lock-unlock-system
