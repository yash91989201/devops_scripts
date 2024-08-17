#!/bin/bash

# Author      : Yashraj Jaiswal
# Date        : 16-08-2024
# Description : Create ec2 instance using script

# global variables
ubuntu_image_id="ami-04a81a99f5ec58529"
key_name="ec2"
security_group_ids="sg-0a37eba5180908964"

setup_aws_cli() {
  sudo apt install unzip
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install

  echo "Configuring aws cli... this is one time process"

  read -rsp "Enter AWS Access Key ID: " access_key
  echo
  read -rsp "Enter AWS Secret Access Key: " secret_key
  echo
  read -rp "Enter default region name: " region
  echo
  read -rp "Enter output format: " output_format
  echo

  if ! {
    aws configure set aws_access_key_id "$access_key"
    aws configure set aws_secret_access_key "$secret_key"
    aws configure set region "$region"
    aws configure set output "$output_format"
  }; then
    echo "Unable to configure aws cli, please try again."
  fi

}

main() {
  if ! aws --version >/dev/null 2>&1; then
    # setup_aws_cli
    echo "aws cli installing"
  else
    echo "AWS CLI installed and configured"
  fi

  # name for created instance
  read -rp "Enter name for ec2 instance: " ec2_name

  # create ec2 instance
  create_ec2_command="aws ec2 run-instances \
  --image-id \"$ubuntu_image_id\" \
  --count 1 \
  --instance-type t2.micro \
  --key-name \"$key_name\" \
  --security-group-ids \"$security_group_ids\" \
  --tag-specifications \"ResourceType=instance,Tags=[{Key=Name,Value=$ec2_name}]\" \
  --query \"Instances[0].InstanceId\" \
  --output text"

  instance_id=$(eval "$create_ec2_command")

  # ping with instance_id to check for running state
  while true; do
    echo "Checking ec2 status..."
    # Get the current status of the instance
    ec2_status_command="aws ec2 describe-instances \
      --instance-ids \"$instance_id\" \
      --query \"Reservations[0].Instances[0].State.Name\" \
      --output text"

    status=$(eval "$ec2_status_command")

    echo "Status of  $instance_id is: $status"

    if [ "$status" == "running" ]; then
      ec2_ip_command="aws ec2 describe-instances \
      --instance-ids \"$instance_id\" \
      --query \"Reservations[0].Instances[0].PublicIpAddress\" \
      --output text"

      ip=$(eval "$ec2_ip_command")
      echo "Instance $instance_id is now running with public ip: $ip"

      break
    fi

    sleep 5
  done
}

main
