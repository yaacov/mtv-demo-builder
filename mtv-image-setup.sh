#!/bin/bash

sudo dnf install podman -y

# Define the username and password
USERNAME="demo"
PASSWORD="demo"

# Create the new user
sudo useradd -m -s /bin/bash $USERNAME

# Set the password for the new user
echo "$USERNAME:$PASSWORD" | sudo chpasswd

# Add user to sudoers
usermod -aG wheel $USERNAME
echo '%wheel ALL=(ALL)       NOPASSWD: ALL' >> /etc/sudoers

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install kubectl /usr/local/bin/kubectl

# Install kind
export VERSION=v0.23.0
curl -LO https://kind.sigs.k8s.io/dl/${VERSION}/kind-linux-amd64
sudo install kind-linux-amd64 /usr/local/bin/kind

# Get mtv UI repository
# Define the URL and the filename
FILENAME="v2.6.3-rc3.tar.gz"
URL="https://github.com/kubev2v/forklift-console-plugin/archive/refs/tags/${FILENAME}"

# Download the tar.gz file
curl -Lo $FILENAME $URL

# Create a directory to extract the contents
EXTRACT_DIR="forklift-console-plugin"
mkdir -p $EXTRACT_DIR-tmp

# Extract the tar.gz file into the directory
tar -xzf $FILENAME -C $EXTRACT_DIR-tmp --strip-components=1

# Copy ci directory
mkdir -p $EXTRACT_DIR
cp -R $EXTRACT_DIR-tmp/ci $EXTRACT_DIR

# Clean up by removing the downloaded tar.gz file and forklift code
rm -rf $EXTRACT_DIR-tmp
rm $FILENAME

# Add forkliftci git dir
forkliftci_dir="$EXTRACT_DIR/ci/forkliftci"

# Chown the repository 
mkdir -p $forkliftci_dir/.git
chown -R $USERNAME:$USERNAME $EXTRACT_DIR
