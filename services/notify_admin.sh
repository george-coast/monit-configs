#!/bin/bash
# Simple notification script example
echo "$(date): Service $1 has changed state to $2" >> /var/log/monit/notify.log
# Here you could add email or messaging integration
