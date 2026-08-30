#!/bin/bash
set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

CONTAINER_USER="dev"
CONTAINER_WORKSPACE="/home/$CONTAINER_USER/robot_ws"

echo "[INFO] Building Embedded Software Environmen (OBC)..."
# Target the 'obc' stage defined in the Dockerfile
docker build --target obc -t polemarchus-obc .

DOCKER_ARGS=(
    -it
    --rm
    --name embedded-environment
    --user "$CONTAINER_USER"
    --network=host
    --ipc=host
    -v "$REPO_ROOT:$CONTAINER_WORKSPACE:rw"
    --group-add dialout
)

if [ -e /dev/arduino_mcu ]; then
    echo "[INFO] Hardware detected: Mounting Arduino MCU."
    DOCKER_ARGS+=("--device=/dev/arduino_mcu:/dev/arduino_mcu")
fi

if [ -e /dev/rplidar ]; then
    echo "[INFO] Hardware detected: Mountin RPLidar."
    DOCKER_ARGS+=("--device=/dev/rplidar:/dev/rplidar")
fi

echo "[INFO] Booting Embedded OBC Container..."
docker run "${DOCKER_ARGS[@]}" polemarchus-obc:latest /bin/bash
