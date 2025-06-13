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

# Create target dir if it doesn't exist
sudo mkdir -p /etc/monit.d


# Copy monit config files
echo "Copying monit configuration files to $TARGET_DIR"
sudo cp -v "$CONFIG_DIR"/*.monitrc "$TARGET_DIR"/

# Set permissions (optional but recommended)
sudo chmod 600 "$TARGET_DIR"/*.monitrc
sudo chown root:root "$TARGET_DIR"/*.monitrc

# Enable monit HTTP interface in /etc/monit/monitrc if not already set
MONITRC="/etc/monit/monitrc"
HTTPD_CONFIG=$(cat <<EOF

set httpd port 2812
    use address localhost  # only allow localhost by default
    allow localhost        # allow localhost to connect
    # optionally add a user/password
    # allow admin:monit
EOF
)

if ! grep -q "set httpd port 2812" "$MONITRC"; then
    echo "Enabling Monit HTTP interface on localhost:2812 in $MONITRC"
    sudo bash -c "echo '$HTTPD_CONFIG' >> $MONITRC"
else
    echo "Monit HTTP interface already configured in $MONITRC"
fi

# Uncomment Monit HTTP interface lines
sudo sed -i 's/^#set httpd port 2812/set httpd port 2812/' /etc/monit/monitrc
sudo sed -i 's/^#    use address localhost/    use address localhost/' /etc/monit/monitrc
sudo sed -i 's/^#    allow localhost/    allow localhost/' /etc/monit/monitrc
sudo sed -i 's/^#    allow admin:monit/    #allow admin:monit/' /etc/monit/monitrc

# Enable and restart monit service
echo "Enabling and restarting monit service..."
sudo systemctl enable monit
sudo systemctl restart monit

echo "Installation and config deployment complete."
