#!/bin/bash
set -e

# Resolve the repository root directory regardless of where the script was called from
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# Configuration Variables
CONTAINER_USER="dev"
CONTAINER_WORKSPACE="/home/$CONTAINER_USER/dev_ws"

# Allow local Docker containers to communicate with the host's X11 Display server
xhost +local:root

# Build the Docker image targeting the Desktop stage
echo "Building the Simulation Environment"
docker build --target dsktp -t polemarchus-desktop .

# Define the base Docker run arguments
DOCKER_ARGS=(
	-it 
	--rm 
	--name=sim-environment 
	--user=dev 
	--network=host 
	--ipc=host 
	--env=DISPLAY 
	-v /tmp/.X11-unix:/tmp/.X11-unix:rw 
	-v $(pwd):$CONTAINER_WORKSPACE:rw 
	--group-add dialout 
)

# Dinamically check for arduino
if [ -e /dev/arduino_mcu ]; then
	echo "Hardware detected: Mounting Arduino MCU."
	DOCKER_ARGS+=("--device=/dev/arduino_mcu:/dev/arduino_mcu")
else
	echo "No hardware detected: Booting without mounting Arduino MCU."
fi

# Dinamically check for rplidar
if [ -e /dev/rplidar ]; then
	echo "Hardware detected: Mounting RPLidar."
	DOCKER_ARGS+=("--device=/dev/rplidar:/dev/rplidar")
else
	echo "No hardware detected: Booting without mounting RPLidar."
fi

# Run the Docker container 
echo "Running the Simulation Environment"
docker run "${DOCKER_ARGS[@]}" polemarchus-desktop:latest /bin/bash
