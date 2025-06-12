#!/bin/bash

# Check if monit is installed
if ! command -v monit &> /dev/null
then
    echo "Monit not found, installing..."
    sudo apt-get update
    sudo apt-get install -y monit
else
    echo "Monit is already installed."
fi

# Define your config source and target
CONFIG_DIR="$(pwd)/services"
TARGET_DIR="/etc/monit.d"

# Copy monit config files
echo "Copying monit configuration files to $TARGET_DIR"
sudo cp -v "$CONFIG_DIR"/*.monitrc "$TARGET_DIR"/

# Set permissions (optional but recommended)
sudo chmod 600 "$TARGET_DIR"/*.monitrc
sudo chown root:root "$TARGET_DIR"/*.monitrc

# Enable and restart monit service
echo "Enabling and restarting monit service..."
sudo systemctl enable monit
sudo systemctl restart monit

echo "Installation and config deployment complete."
