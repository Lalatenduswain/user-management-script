#!/bin/bash
# Author: Lalatendu K Swain
# Path to the file containing usernames
usernames_file="userlist"

# Check if the usernames file exists
if [ ! -f "$usernames_file" ]; then
    echo "Usernames file not found: $usernames_file"
    exit 1
fi

# Array to store usernames
declare -a users=()

# Read usernames from file and populate the array
while IFS= read -r line; do
    users+=("$line")
done < "$usernames_file"

# Set the passphrase
passphrase="123456789"  # Consider using a more secure method to handle passphrases

# Function to generate SSH key pair with passphrase and KDF rounds
generate_ssh_key() {
    local user="$1"
    local key_name="$2"

    echo "Generating SSH key pair for $user"
    # Ensure ~/.ssh directory exists
    mkdir -p ~/.ssh
    ssh-keygen -t ed25519 -a 100 -C "Login to Prod Server from ${user} SYSTEM" -N "$passphrase" -f ~/.ssh/"$key_name"
    if [ $? -ne 0 ]; then
        echo "Failed to generate key for $user"
    else
        echo "Key generated successfully for $user"
    fi
}

# Main script
for user in "${users[@]}"; do
    key_name="${user}_ed25519_key"
    generate_ssh_key "$user" "$key_name"
done
