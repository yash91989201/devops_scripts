#!/bin/bash

# Author      : Yashraj Jaiswal
# Date        : 18/08/2024
# Description : Monitor common AWS resources such as EC2, S3, Lambda, IAM

set +x

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

s3_stats() {
  echo "Printing S3 stats"
  aws s3 ls
}

ec2_stats() {
  echo "Printing EC2 stats"
  aws ec2 describe-instances \
    --query \
    "Reservations[*].Instances[*].{Name:Tags[0].Value,ID:InstanceId,SSHKey:KeyName,PublicIP:PublicIpAddress}" \
    --output table
}

lambda_stats() {
  echo "Printing Lambda stats"
  aws lambda list-functions
}

iam_stats() {
  echo "Printing IAM stats"
  aws iam list-users
}

main() {
  if ! aws --version >/dev/null 2>&1; then
    setup_aws_cli
    echo "AWS CLI not found! Installing now"
  fi

  echo
  # print stats
  s3_stats
  echo
  ec2_stats
  echo
  lambda_stats
  echo
  iam_stats
  echo
}

main
