#!/bin/bash

# Author: Yashraj Jaiswal
# Date: 14/08/2024
# Description: Interactive file and directory explorer

# print welcome message for user
echo "Welcome to an Interactive file and directory explorer"

# display current directory contents in a formatted way
echo "Files and directories in $PWD"
ls -lh --block-size=MB | sed 1d | awk '{print "- ",$NF,"\t","(",$5,")"}'

while true;
do
  # prompt user for an input
  read -p "Enter a line of text (press enter to exit)" input

  # -z option tests for empty value
  if [[ -z $input ]]; then
    echo "Exiting interactive explorer"
    exit 1
  else
    # #on string variable returns string length just like .length()
    input_length=${#input}
    # print the character count on screen
    echo "Character count $input_length"
  fi
done


