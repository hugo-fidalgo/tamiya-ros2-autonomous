#!/usr/bin/env bash
set -e

RULES_FILE="/etc/udev/rules.d/99-tamiya-hardware.rules"

echo "[INFO] Generating hardware symlinks..."

# Create the udev rules file
sudo tee ${RULES_FILE} > /dev/null << 'EOF'

# Arduino MCU Serial Bridge Endpoint
SUBSYSTEM=="tty", ATTRS{idVendor}=="2341", ATTRS{idProduct}=="1002", SYMLINK+="arduino_mcu", MODE="0666"

# RPLidar C1 Serial Interface Endpoint
KERNEL=="ttyUSB*", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", MODE:="0666", SYMLINK+="rplidar", MODE="0666"
EOF

echo "[INFO] Reloading udev control engine..."
sudo udevadm control --reload-rules
sudo udevadm trigger

echo "[INFO] Hardware endpoint setup complete. Active symlink:"
ls -l /dev/rplidar /dev/arduino_mcu || true
