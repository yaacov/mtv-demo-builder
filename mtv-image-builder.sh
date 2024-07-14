#!/usr/bin/env bash

set -euo pipefail

script_dir=$(realpath $(dirname "$0"))

# Install qemu and libguestfs tools
#sudo dnf install libguestfs-tools-c qemu-kvm qemu-img

BASE_IMAGE=Fedora-Cloud-Base-Generic.x86_64-40-1.14.qcow2
IMAGE=fedora-cloud.qcow2
IMAGE_STEP1=fedora-cloud-clean.qcow2

SCRIPT=${script_dir}/mtv-image-setup.sh
FIRST_BOOT=${script_dir}/first-boot.sh
SERVICE=${script_dir}/kind-control-plane.service

# Download base image
if [ -e "${BASE_IMAGE}" ]; then
    echo "Base image exists."
else
    echo "Downloading base imgae ..."
    curl -LO https://download.fedoraproject.org/pub/fedora/linux/releases/40/Cloud/x86_64/images/${BASE_IMAGE}
fi

cp ${BASE_IMAGE} ${IMAGE}

# Run setup script
echo "Customize base imgae ..."
virt-customize -a ${IMAGE} \
  --uninstall cloud-init \
  --upload ${SCRIPT}:/mtv-image-setup.sh \
  --upload ${FIRST_BOOT}:/first-boot.sh \
  --upload ${SERVICE}:/etc/systemd/system/kind-control-plane.service \
  --run-command 'bash /mtv-image-setup.sh' \
  --firstboot ${FIRST_BOOT}

# Copy and gzip the image before first run (clean image)
cp ${IMAGE} ${IMAGE_STEP1}
tar -czvf ${IMAGE_STEP1}.tar.gz ${IMAGE_STEP1}

echo "=================================================="
echo "First run of the virtual machine needs to run connected"
echo " - Build kind cluster"
echo " - Install migration toolkit for virtualization"
echo ""
echo " IMPORTANT - first boot script will run automatically after"
echo "  first time the machine boot, it may take a few minutes,"
echo "  wait for the first boot script to finish before shuting"
echo "  the virtual machine down"
echo ""
echo "login:"
echo "   ssh -p 2222 demo@localhost # password: demo"
echo ""
echo "https://127.0.0.1:30443 - migration toolkit web user interface"
echo "https://127.0.0.1:30444/providers - migration toolkit inventory server"
echo "=================================================="
echo ""

# Start the virtual machine
# After first run the virtual machine image will be bigger and include all the
# container images and code to run disconnected
read -r -p "Do you want to start the virtual machine for first run now? [y/N]: " response
response=${response,,} # tolower

if [[ "$response" =~ ^(yes|y)$ ]]; then
    qemu-kvm -name fedora-cloud \
        -m 4096 -smp 4 \
        -cpu host \
        -drive file=${IMAGE},if=virtio \
        -netdev user,id=net0,hostfwd=tcp::2222-:22,hostfwd=tcp::30443-:30443,hostfwd=tcp::30444-:30444 \
        -device virtio-net,netdev=net0 \
        -nographic
fi
