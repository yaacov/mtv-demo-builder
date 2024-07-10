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
