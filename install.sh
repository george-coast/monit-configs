#!/bin/bash
# Example install script to copy monit configs to /etc/monit.d/
echo "Installing monit configs..."

sudo cp services/*.monitrc /etc/monit.d/
sudo chmod 600 /etc/monit.d/*.monitrc
sudo systemctl restart monit

echo "Installation complete."
