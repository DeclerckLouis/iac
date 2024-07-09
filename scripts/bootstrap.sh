#!/bin/bash

# This script will install ansible and run the maser-node.yaml playbook on the local machine.
# This script is intended to be run on the master node.
# It has only been tested on a raspberry pi 4 running ubuntu 22.04.

# Test user
user_type=$(whoami)
if [ $user_type == "root" ]; then
    echo "User is root. Proceeding with installation."
    echo ""
else
    echo "Please run this script as root."
    exit 1
fi

# Apt update 
echo "Updating package list..."
apt-get -y update > /dev/null
echo "Done."
echo ""

# Install Python
echo "Installing python..."
apt-get -y install python3 > /dev/null
echo "Done."
echo ""

# Install pip
echo "Installing python3-pip..."
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py > /dev/null
python3 get-pip.py > /dev/null
echo "Done."
echo ""

# Install Ansible
echo "Installing Ansible..."
python3 -m pip install ansible
ansible_version = $(ansible --version)
echo "Ansible version: $ansible_version"
echo "Done."

cd ../ansible

