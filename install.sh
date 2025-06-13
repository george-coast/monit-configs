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

# Ensure monit includes /etc/monit.d/*.monitrc
if ! grep -q '^include /etc/monit.d/\*\.monitrc' /etc/monit/monitrc; then
  echo "include /etc/monit.d/*.monitrc" >> /etc/monit/monitrc
else
  # Uncomment if commented out
  sed -i 's/^#\s*include \/etc\/monit.d\/\*\.monitrc/include \/etc\/monit.d\/\*\.monitrc/' /etc/monit/monitrc
fi

# check to see if the openvpn service is running and will start monitoring if it does 
if monit summary | grep -q "openvpn"; then
    sudo monit monitor openvpn
fi

cat << 'EOF' > /etc/monit.d/openvpn.monitrc
check process openvpn matching "openvpn"
  start program = "/bin/systemctl start openvpn-server@server.service"
  stop program  = "/bin/systemctl stop openvpn-server@server.service"
  if failed port 1194 type udp then restart
  if 5 restarts within 5 cycles then unmonitor
EOF

# Define source and target
SOURCE="/home/mic-733ao/monit-configs/services/openvpn.monitrc"
TARGET="/etc/monit.d/openvpn_service.monitrc"

# Remove old symlink or file if it exists
if [ -L "$TARGET" ] || [ -f "$TARGET" ]; then
    echo "Removing existing monit config at $TARGET..."
    sudo rm -f "$TARGET"
fi

# Create symbolic link
echo "Linking $SOURCE to $TARGET..."
sudo ln -s "$SOURCE" "$TARGET"

# Reload monit
echo "Reloading Monit..."
sudo monit reload

echo "Done. Monit config for openvpn_service is set."

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
