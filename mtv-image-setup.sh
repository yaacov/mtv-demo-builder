#!/bin/bash

sudo dnf install podman git -y

# ===============================
# Set demo user
# ===============================

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

# ===============================
# Install kubectl and kind
# ===============================

# Install kubectl
VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
curl -LO https://dl.k8s.io/release/${VERSION}/bin/linux/amd64/kubectl
sudo install kubectl /usr/local/bin/kubectl

# Install kind
VERSION=$(curl -s https://api.github.com/repos/kubernetes-sigs/kind/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
curl -LO https://kind.sigs.k8s.io/dl/${VERSION}/kind-linux-amd64
sudo install kind-linux-amd64 /usr/local/bin/kind

# ===============================
# Clone CI scripts
# ===============================

# Define the repository URL and the extraction directory
REPO_URL="https://github.com/kubev2v/forklift-console-plugin.git"
EXTRACT_DIR="forklift-console-plugin"

# Create a directory to extract the contents
mkdir -p $EXTRACT_DIR-tmp

# Clone the main branch of the repository into the directory
git clone --branch main --single-branch $REPO_URL $EXTRACT_DIR-tmp

# Copy ci directory
mkdir -p $EXTRACT_DIR
cp -R $EXTRACT_DIR-tmp/ci $EXTRACT_DIR

# ===============================
# Cleanup
# ===============================

# Clean up by removing the downloaded tar.gz file and forklift code
rm -rf $EXTRACT_DIR-tmp
rm $FILENAME

# Chown the repository 
mkdir -p $EXTRACT_DIR/ci/forkliftci/.git
chown -R $USERNAME:$USERNAME $EXTRACT_DIR

# ===============================
# Set first boot script
# ===============================
chmod +x /firstboot.sh
systemctl enable firstboot.service
