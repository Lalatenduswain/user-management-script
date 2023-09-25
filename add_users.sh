#!/bin/bash

## Author : Lalatendu Swain | https://github.com/Lalatenduswain
## Website : https://blog.lalatendu.info/

# Define an array of usernames
usernames=("username1" "username2" "username3")

# Define an array of passwords
passwords=("password1" "password2" "password3")

# Loop through the arrays and add users
for ((i=0; i<${#usernames[@]}; i++)); do
  username="${usernames[i]}"
  password="${passwords[i]}"
  
  # Add the user
  sudo useradd "$username" -m
  
  # Set the user's password
  echo "$username:$password" | sudo chpasswd
done
