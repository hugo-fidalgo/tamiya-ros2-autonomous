#!/usr/bin/env bash
set -e

RULES_FILE="/etc/udev/rules.d/99-tamiya-hardware.rules"

echo "[INFO] Generating hardware symlinks..."

# Create the udev rules file
sudo bash-c "cat << 'EOF' > ${RULES_FILE}

# Arduino MCU Serial Bridge Endpoint
SUBSYSTEM=="tty", ATTRS{idVendor}=="2341", ATTRS{idProduct}=="1002", SYMLINK+="arduino_mcu"

# RPLidar C1 Serial Interface Endpoint
KERNEL=="ttyUSB*", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", MODE:="0666", SYMLINK+="rplidar"
EOF"

echo "[INFO] Reloading udev control engine..."
sudo udevadm control --reload-rules
sudo udevadm trigger

echo "[INFO] Hardware endpoint setup complete. Active symlink:"
ls -l /rev/rplidar /dev/arduino_mcu || true
