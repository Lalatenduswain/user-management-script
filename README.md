# Add Multiple Users and Passwords in Ubuntu

This repository contains tools and scripts for managing users on a Linux system, specifically Ubuntu. It provides two methods for adding multiple user accounts and setting their passwords. You can either use a Bash script or a text file to automate the process.

## Method 1: Using a Script

Create a Bash script to add multiple users and set their passwords. This method is suitable when you have a small number of users to add.

### Usage

1. Clone this repository to your Ubuntu system or create a new file called `add_users.sh`:

    ```bash
   git clone https://github.com/Lalatenduswain/Adding-Multiple-Users-with-Passwords-in-Ubuntu.git
    ```

2. Make the script executable:
    ```bash
    chmod +x add_users.sh
    ```

3. Run the script:
    ```bash
    ./add_users.sh
    ```

This script will create the specified users and set their passwords.

## Method 2: Using a Text File

Add users and passwords by providing the user information in a text file. This method is suitable for adding a larger number of users.

### Usage

1. Create a text file (e.g., `userlist.txt`) and add user information in the following format, one user per line:

    ```
    username1 password1
    username2 password2
    username3 password3
    ```

2. Create a Bash script to read the file and create users with passwords:

    ```bash
    #!/bin/bash

    # Specify the path to the user information file
    userfile="userlist.txt"

    # Read the file line by line and add users
    while IFS=" " read -r username password; do
      # Add the user
      sudo useradd "$username" -m
      
      # Set the user's password
      echo "$username:$password" | sudo chpasswd
    done < "$userfile"
    ```

3. Make the script executable:
    ```bash
    chmod +x add_users_from_file.sh
    ```

4. Run the script:
    ```bash
    ./add_users_from_file.sh
    ```

This script will add users and set their passwords based on the information in the `userlist.txt` file.

## Donations

If you want to show your appreciation, you can donate via [Buy Me a Coffee](https://www.buymeacoffee.com/lalatendu.swain).

## Disclaimer

**Author**: Lalatendu Swain | [GitHub](https://github.com/Lalatenduswain) | [Website](https://blog.lalatendu.info/)

This script is provided as-is and may require modifications or updates based on your specific environment and requirements. Use it at your own risk. The authors of the script are not liable for any damages or issues caused by its usage.
