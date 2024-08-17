#!/bin/bash

# Author: Yashraj Jaiswal
# Date: 14/08/2024
# Description: log rotation script

# validating script input for dir to backup

dir_path="$1"
backup_dir="/var/backups"
max_backups=3

delete_oldest_backup(){
  echo "$max_backups backups exist in total, deleting the oldest backup."

  oldest_backup_file=$(find "$backup_dir" -type f -name "backup*.tar.gz" | sort | head -n 1)
  
  if [[ -n "$oldest_backup_file" ]]; then
    echo "Deleting oldest backup file: $oldest_backup_file"
    if sudo rm "$oldest_backup_file"; then
      echo "Oldest backup deleted successfully."
    else
      echo "Error: Failed to delete the oldest backup."
      exit 1
    fi
  else
    echo "Error: No backups found to delete."
    exit 1
  fi
}

create_backup(){
  backup_file="backup_$(date +%d_%m_%Y_%H_%M_%S).tar.gz"
  # Create backup 
  if sudo tar -czf "$backup_dir/$backup_file" "$dir_path" > /dev/null 2>&1; then
    echo "Backup created successfully."
    echo "List of backups created:"
    sudo find "$backup_dir" -type f -name 'backup*.tar.gz' -exec ls -lh {} + | awk '{print "-", $NF, "\t(", $5, ")"}'
  else
    echo "Unable to create backup, try again."
    exit 1
  fi
}

main (){

if [[ "$#" -ne 1 ]]; then
  echo "Usage: ./log_rotation.sh <path-to-directory>"
  echo "Hint: Please provide the absolute path of the directory to backup."
  exit 1
fi 

# Check if backup directory exists
if [[ ! -d "$backup_dir" ]]; then
  echo "Error: Backup directory $backup_dir does not exist."
  exit 1
fi

total_backups=$(find "$backup_dir" -type f -name "backup*.tar.gz" | wc -l)
echo "Total backups: $total_backups"


if ((total_backups >= max_backups)); then
  delete_oldest_backup
  create_backup
else
  create_backup
fi
}

main "$@"
