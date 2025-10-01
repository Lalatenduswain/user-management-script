👤 User Management Script

This **Bash script** is designed to help system administrators **create and manage Linux users** efficiently.
It provides both **interactive user management** and **bulk user operations** (via userlist file).

📌 Features include:

* Add a single user interactively
* Add users from a userlist file
* Delete a single user safely (non-system accounts only)
* Delete all users listed in a userlist file
* Generate SSH keys automatically for users
* Setup passwordless login with `authorized_keys`
* Enforce secure permissions for `.ssh` directory and keys
* Menu-driven interface for ease of use

![User Management App Screenshot](https://raw.githubusercontent.com/Lalatenduswain/user-management-script/master/image/Linux%20User.png "User Management")

---

## ✨ Features

* ✅ Create a new user with a home directory
* ✅ Add user to `sudo/wheel` group for elevated privileges
* ✅ Generate **2048-bit RSA key pair** automatically
* ✅ Configure passwordless SSH login
* ✅ Delete non-system users safely (protects system accounts)
* ✅ Bulk user creation/removal via a userlist file
* ✅ Interactive confirmation for user deletion
* ✅ Output private key securely for new accounts

---

## 📖 Installation Guide

### 🔧 Prerequisites

* Linux system (Ubuntu/Debian/RHEL/CentOS supported)
* `bash` shell
* Run as `root` or with `sudo` privileges
* Required packages:

```bash
# Debian/Ubuntu
sudo apt install sudo passwd openssh-client openssh-server -y  

# RHEL/CentOS
sudo yum install sudo passwd openssh -y  
```

---

### 📂 Clone the Repository

```bash
git clone https://github.com/Lalatenduswain/user-management-script.git
cd user-management-script
```

---

### ▶️ Usage

Make the script executable:

```bash
chmod +x user_management.sh
```

Run the script as **root**:

```bash
sudo ./user_management.sh
```

---

### 📝 Menu Options

1. **Add users from a userlist file**

   * Provide a file containing usernames (one per line).
   * Users are created automatically with SSH keys.

2. **Add a single user interactively**

   * Enter a dummy username (e.g., `newuser`).
   * SSH keypair is generated, and public key added to `authorized_keys`.
   * Private key is displayed (securely copy to user).

3. **Remove a single user**

   * Enter a username (UID ≥ 1000 only).
   * Confirms before deletion.
   * Removes home directory and `.ssh` keys.

4. **Remove all users listed in a userlist file**

   * Deletes all listed users safely (skips system accounts).

---

## ⚙️ Script Overview

The script provides **two types of workflows**:

* **Interactive mode** → Create or delete users one at a time.
* **Batch mode** → Use a userlist file to create/delete multiple accounts.

Internally, it uses:

* `useradd`, `usermod`, `chpasswd`, `userdel -r`
* `ssh-keygen` for key generation
* Secure chmod/chown settings for `.ssh`

---

## 🚀 Benefits

* Saves time in managing multiple Linux users
* Automates SSH key provisioning
* Enforces security best practices
* Prevents accidental deletion of system accounts (UID < 1000 protected)
* Flexible: Works for both single and bulk user management

---

## ⚠️ Disclaimer | Running the Script

**Author:** Lalatendu Swain | [GitHub](https://github.com/Lalatenduswain) | [Website](https://blog.lalatendu.info/)

This script is provided as-is and may require modifications or updates based on your specific environment and requirements. Use it at your own risk. The author is not liable for any damages or issues caused by its usage.

---

## 💖 Support & Donations

If you find this script useful and want to show your appreciation, you can donate via:
👉 [Buy Me a Coffee](https://www.buymeacoffee.com/lalatendu.swain)

---

## 🛠️ Issues & Contributions

Encountering issues? Don’t hesitate to submit an issue:
🔗 [GitHub Issues](https://github.com/Lalatenduswain/user-management-script/issues)

Contributions are welcome! Fork the repo, make improvements, and open a Pull Request.

---

📌 **Repository:** [https://github.com/Lalatenduswain/user-management-script](https://github.com/Lalatenduswain/user-management-script)
