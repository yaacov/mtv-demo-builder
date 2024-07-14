#!/usr/bin/env bash

set -euo pipefail

# Deply kind cluster + MTV operator
bash /forklift-console-plugin/ci/deploy-all.sh --no-kubevirt

# Enable kind-control-plane as a service
systemctl enable kind-control-plane.service

# Copy kubeconfig to demo useer
sudo kind export kubeconfig
mkdir ~demo/.kube
sudo cp ~/.kube/config ~demo/.kube/config

# Change owner to demo user
chown demo:demo -R ~demo/.kube

echo ""
echo "=================================================="
echo ""
echo "MTV demo virtual machine is ready"
echo ""
echo "login:"
echo "   user: demo, password: demo"
echo ""
echo "ssh login:"
echo "   ssh -p 2222 demo@localhost # password: demo"
echo ""
echo "https://127.0.0.1:30443 - migration toolkit web user interface"
echo "https://127.0.0.1:30444/providers - migration toolkit inventory server"
echo ""
echo "=================================================="
echo ""