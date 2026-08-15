#!/bin/bash

# Allow local Docker containers to communicate with the host's X11 Display server
xhost +local:root

# Build the Docker image targeting the Desktop stage
echo "Building the Simulation Environment"
docker build --target dsktp -t polemarchus-desktop .

# Run the Docker container 
echo "Running the Simulation Environment"
docker run -it --rm \
	--name=sim-environment \
	--user=dev \
	--network=host \
	--ipc=host \
	--env=DISPLAY \
	-v /tmp/.X11-unix:/tmp/.X11-unix:rw \
	polemarchus-desktop \
	/bin/bash
