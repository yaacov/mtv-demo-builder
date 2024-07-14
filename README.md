# MTV Demo Builder

This repository contains a collection of scripts to build a .qcow2 image running the Migration Toolkit for Virtualization (MTV).

## Architecture

The MTV Demo Builder is structured with several scripts designed to create and configure a Fedora cloud image. These scripts include:

1. **mtv-image-builder**: This script downloads the Fedora cloud .qcow image, sets up a demo user, and installs the setup and first-boot scripts.
2. **mtv-image-setup**: This script runs on the .qcow image before the first boot. It is used by the builder to set up the image.
3. **first-boot**: This script runs after the first boot, builds a kind cluster, downloads the necessary container images, and installs MTV on the cluster.
4. **kind-control-plan.service**: A service script to manage the kind cluster control plane.

## Scripts

### mtv-image-builder
This script is responsible for:
- Downloading the Fedora cloud .qcow image.
- Setting up the demo user.
- Installing the setup and first-boot scripts that will build a kind cluster and install MTV on the first boot.

### mtv-image-setup
This script runs on the .qcow image before the first boot and is used by the builder to set up the image.

### first-boot
This script runs after the first boot, builds the cluster, downloads the necessary container images, and installs MTV on the cluster.

### kind-control-plan.service
A service script that manages the kind cluster control plane.

## Building the image

```sh
bash mtv-image-builder.sh
```

The script will download the Fedora clound image, customize it, and ask to run for the first boot.
If successful the script will create a file `fedora-cloud.qcow2` that will include a fedora machine with demo user running kind cluster with MTV installed.

## Result

After the first boot, we have a .qcow image with a kind cluster installed and MTV running in the cluster. The VM will expose ports to access the UI, API services, and an SSH server.

- **Migration Toolkit Web User Interface**: `https://127.0.0.1:30443`
- **Migration Toolkit Inventory Server**: `https://127.0.0.1:30444`
- **SSH Server**: Port 2222 (user: `demo`, password: `demo`)

To log into the machine via SSH:
```sh
ssh -p 2222 demo@localhost
# Password: demo
```

## Running the QCOW Image

To run the .qcow image, use the following command:
```sh
IMAGE=fedora-cloud.qcow2

curl -Lo ${IMAGE}.tar.gz https://github.com/yaacov/mtv-demo-builder/releases/download/v0.0.1/fedora-cloud-clean.qcow2.tar.gz
tar -xzvf ${IMAGE}.tar.gz

# IMPORATNT: on first boot, wait for first boot script to complete.
qemu-kvm -name fedora-cloud \
        -m 4096 -smp 4 \
        -cpu host \
        -drive file=${IMAGE},if=virtio \
        -netdev user,id=net0,hostfwd=tcp::2222-:22,hostfwd=tcp::30443-:30443,hostfwd=tcp::30444-:30444,hostfwd=tcp::6443-:6443 \
        -device virtio-net,netdev=net0 \
        -nographic
```

Replace `${IMAGE}` with the path to your .qcow2 image file.

After the VM finish booting and a login prompt apear, wait for the first boot script to start and finsh (only on first boot), then go to web console at: https://127.0.0.1:30443

## Contact

For any issues or questions, please open an issue in this repository.
