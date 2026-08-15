#!/bin/bash
set -e

# Source the core ROS 2 installation
source /opt/ros/humble/setup.bash

# Execute the command passed into the container
exec "$@"
