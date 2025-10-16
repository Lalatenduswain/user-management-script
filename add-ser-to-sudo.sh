#!/bin/bash

## Author : Lalatendu Swain | https://github.com/Lalatenduswain
## Website : https://blog.lalatendu.info/

# Check if the script is being run with root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root."
  exit 1
fi

# Path to the userlist file in the current directory
script_dir=$(dirname "$0")
userlist_file="$script_dir/userlist"
sudo_userlist_file="$script_dir/sudousers"  # New file for sudo users (one username per line)

# Set the passphrase for SSH keys
passphrase="123456789"  # Consider using a more secure method for handling passphrases

# Function to add users from the userlist file
add_users_from_file() {
    if [ ! -f "$userlist_file" ]; then
        echo "User list file not found: $userlist_file"
        exit 1
    fi

    while IFS=' ' read -r username password || [[ -n "$username" ]]; do
        # Check if the user already exists
        if id "$username" &>/dev/null; then
            echo "User $username already exists."
            continue
        fi

        # Add the user with /bin/bash as the default shell
        useradd -m -s /bin/bash "$username"
        if [ $? -ne 0 ]; then
            echo "Failed to add user $username."
            continue
        fi
    
        # Set the user's password
        echo "$username:$password" | chpasswd
        if [ $? -ne 0 ]; then
            echo "Failed to set password for user $username."
            continue
        fi

        # Create and set permissions for the SSH directory
        user_ssh_dir="/home/$username/.ssh"
        mkdir -p "$user_ssh_dir"
        chmod 700 "$user_ssh_dir"

        # Generate SSH key pair
        key_name="${username}_ed25519_key"
        echo "Generating SSH key pair for $username"
        ssh-keygen -t ed25519 -a 100 -C "Login to Prod Server from ${username} SYSTEM" -N "$passphrase" -f "$user_ssh_dir/$key_name"
        if [ $? -ne 0 ]; then
            echo "Failed to generate key for $username."
            continue
        fi

        # Create SSH-related files and set permissions
        touch "$user_ssh_dir/authorized_keys" "$user_ssh_dir/known_hosts" "$user_ssh_dir/config"
        chmod 600 "$user_ssh_dir/authorized_keys" "$user_ssh_dir/config"
        chmod 644 "$user_ssh_dir/known_hosts"
        chmod 600 "$user_ssh_dir/$key_name"
        chmod 644 "$user_ssh_dir/${key_name}.pub"

        # Change ownership of the SSH directory and files
        chown -R "$username:$username" "$user_ssh_dir"

        # Add the 'll' alias to .bashrc
        echo "alias ll='ls -l'" >> /home/$username/.bashrc
    done < "$userlist_file"
}

# Function to add a single user interactively
add_single_user() {
    # Prompt for the username
    read -p "Enter the desired username: " username

    # Check if the user already exists
    if id "$username" &>/dev/null; then
        echo "User $username already exists."
        return
    fi

    # Prompt for the password (hidden input)
    read -s -p "Enter the password for $username: " password
    echo

    # Create the user with their home directory
    useradd -m -s /bin/bash "$username"
    if [ $? -ne 0 ]; then
        echo "Failed to add user $username."
        return
    fi

    # Set the password
    echo "$username:$password" | chpasswd
    if [ $? -ne 0 ]; then
        echo "Failed to set password for user $username."
        return
    fi
    echo "Password for user $username set."

    # Create and set permissions for the SSH directory
    user_ssh_dir="/home/$username/.ssh"
    mkdir -p "$user_ssh_dir"
    chmod 700 "$user_ssh_dir"

    # Generate SSH key pair
    key_name="${username}_ed25519_key"
    echo "Generating SSH key pair for $username"
    ssh-keygen -t ed25519 -a 100 -C "Login to Prod Server from ${username} SYSTEM" -N "$passphrase" -f "$user_ssh_dir/$key_name"
    if [ $? -ne 0 ]; then
        echo "Failed to generate key for $username."
        return
    fi

    # Create SSH-related files and set permissions
    touch "$user_ssh_dir/authorized_keys" "$user_ssh_dir/known_hosts" "$user_ssh_dir/config"
    chmod 600 "$user_ssh_dir/authorized_keys" "$user_ssh_dir/config"
    chmod 644 "$user_ssh_dir/known_hosts"
    chmod 600 "$user_ssh_dir/$key_name"
    chmod 644 "$user_ssh_dir/${key_name}.pub"

    # Change ownership of the SSH directory and files
    chown -R "$username:$username" "$user_ssh_dir"
}

# Function to display manually added users and remove a user
remove_user() {
    echo "Manually added users on the system (UID >= 1000):"
    IFS=$'\n' read -r -d '' -a users < <( getent passwd | awk -F: '($3 >= 1000) && ($1 != "nobody") { print $1 }' && printf '\0' )

    if [ ${#users[@]} -eq 0 ]; then
        echo "No manually added users available for removal."
        return
    fi

    for i in "${!users[@]}"; do
        echo "$((i+1))) ${users[i]}"
    done

    echo "Enter the number of the user you want to remove:"
    read -r number

    selected_user="${users[number-1]}"

    if [ -n "$selected_user" ]; then
        echo "Removing user: $selected_user"
        userdel -r "$selected_user" 2>/dev/null
        if [ $? -ne 0 ]; then
            echo "Failed to remove user $selected_user."
        fi
    else
        echo "Invalid selection."
    fi
}

# New function to remove all users listed in userlist
remove_all_users_from_file() {
    if [ ! -f "$userlist_file" ]; then
        echo "User list file not found: $userlist_file"
        exit 1
    fi

    echo "WARNING: You are about to remove all users listed in $userlist_file."
    read -p "Are you sure you want to proceed? Type 'yes' to confirm: " confirmation
    if [ "$confirmation" != "yes" ]; then
        echo "User removal cancelled."
        return
    fi
    read -p "This is your final warning. Type 'yes' to confirm: " final_confirmation
    if [ "$final_confirmation" != "yes" ]; then
        echo "User removal cancelled."
        return
    fi
    while IFS=' ' read -r username password || [[ -n "$username" ]]; do
        echo "Removing user: $username"
        userdel -r "$username" 2>/dev/null
        if [ $? -ne 0 ]; then
            echo "Failed to remove user $username."
        fi
    done < "$userlist_file"
    echo "All listed users have been removed."
}

# New function to add users from sudo user list file to the sudo group
add_sudo_from_file() {
    if [ ! -f "$sudo_userlist_file" ]; then
        echo "Sudo user list file not found: $sudo_userlist_file"
        echo "Create a file named 'sudousers' in the script directory with one username per line."
        exit 1
    fi

    echo "Adding users from $sudo_userlist_file to the sudo group..."
    while IFS= read -r username || [[ -n "$username" ]]; do
        # Trim leading/trailing whitespace
        username=$(echo "$username" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        if [ -z "$username" ]; then
            continue
        fi

        # Check if the user exists
        if ! id "$username" &>/dev/null; then
            echo "User $username does not exist. Skipping."
            continue
        fi

        # Check if already in sudo group
        if groups "$username" | grep -qw "sudo"; then
            echo "User $username is already in the sudo group. Skipping."
            continue
        fi

        # Add to sudo group
        usermod -aG sudo "$username"
        if [ $? -ne 0 ]; then
            echo "Failed to add user $username to the sudo group."
        else
            echo "Successfully added user $username to the sudo group."
        fi
    done < "$sudo_userlist_file"
    echo "Sudo group updates completed."
}

# Main script execution
echo "Choose an action:"
echo "1) Add users from file"
echo "2) Add a single user interactively"
echo "3) Remove a user"
echo "4) Remove all users from file"
echo "5) Add users from sudo file to sudo group"
read -r -p "Enter your choice (1/2/3/4/5): " action

case $action in
    1)
        add_users_from_file
        ;;
    2)
        add_single_user
        ;;
    3)
        remove_user
        ;;
    4)
        remove_all_users_from_file
        ;;
    5)
        add_sudo_from_file
        ;;
    *)
        echo "Invalid choice. Please enter 1, 2, 3, 4, or 5."
        ;;
esac
