#!/bin/bash
set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# Wait for udev rules to populate hardware endpoints
echo "[AUTOSTART] Waiting for hardware endpoints..."
while [ ! -e /dev/rplidar ] || [ ! -e /dev/arduino_mcu ]; do
    sleep 1
done

echo "[AUTOSTART] Starting Embedded Container..."
docker run --rm \
    --name embedded-environment-autostart \
    --user dev \
    --network=host \
    --ipc=host \
    --device=/dev/rplidar:/dev/rplidar \
    --device=/dev/arduino_mcu:/dev/arduino_mcu \
    -v "$REPO_ROOT:/home/dev/robot_ws:rw" \
    polemarchus-obc:latest \
    /bin/bash -c "source /opt/ros/humble/setup.bash && source /home/dev/robot_ws/install/setup.bash && ros2 launch tamiya_rover_description hardware.launch.py"
