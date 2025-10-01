#!/bin/bash

# Check if script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "You must run this script as root or with sudo."
    exit 1
fi

# Function to create user
create_user() {
    read -p "Enter username: " USERNAME
    read -sp "Enter password: " PASSWORD
    echo

    if [ -z "$USERNAME" ] || [ -z "$PASSWORD" ]; then
        echo "Username and password are required."
        exit 1
    fi

    # Create user with home directory
    useradd -m "$USERNAME"
    echo "$USERNAME:$PASSWORD" | chpasswd

    # Add to sudo/wheel group
    usermod -aG wheel "$USERNAME"
    usermod -aG root "$USERNAME"

    # Create SSH directory
    mkdir -p /home/"$USERNAME"/.ssh
    chmod 700 /home/"$USERNAME"/.ssh

    # Generate SSH key pair
    ssh-keygen -t rsa -b 2048 -f /home/"$USERNAME"/.ssh/id_rsa -N "" -q

    # Set permissions
    chmod 600 /home/"$USERNAME"/.ssh/id_rsa
    chmod 644 /home/"$USERNAME"/.ssh/id_rsa.pub

    # Add public key to authorized_keys
    cat /home/"$USERNAME"/.ssh/id_rsa.pub > /home/"$USERNAME"/.ssh/authorized_keys
    chmod 600 /home/"$USERNAME"/.ssh/authorized_keys

    # Fix ownership
    chown -R "$USERNAME":"$USERNAME" /home/"$USERNAME"/.ssh

    # Show private key so you can copy it securely
    echo "===================================================="
    echo "Private SSH Key for $USERNAME (KEEP THIS SAFE):"
    cat /home/"$USERNAME"/.ssh/id_rsa
    echo "===================================================="
    echo "User $USERNAME has been created with root access and SSH key-based login enabled."
}

# Function to delete user
delete_user() {
    read -p "Enter username to delete: " USERNAME

    # Check if user exists
    if ! id "$USERNAME" &>/dev/null; then
        echo "User $USERNAME does not exist."
        exit 1
    fi

    # Get UID of the user
    USER_UID=$(id -u "$USERNAME")

    # Protect system accounts (UID < 1000 usually system users)
    if [ "$USER_UID" -lt 1000 ]; then
        echo "Refusing to delete system user: $USERNAME (UID: $USER_UID)"
        exit 1
    fi

    read -p "Are you sure you want to delete user $USERNAME and their home directory? (yes/no): " CONFIRM
    if [ "$CONFIRM" == "yes" ]; then
        userdel -r "$USERNAME"
        echo "User $USERNAME has been deleted."
    else
        echo "Aborted."
    fi
}

# Main menu
echo "What do you want to do?"
echo "1) Create a new user"
echo "2) Delete an existing user"
read -p "Choose option [1/2]: " CHOICE

case $CHOICE in
    1) create_user ;;
    2) delete_user ;;
    *) echo "Invalid choice. Exiting." ;;
esac
