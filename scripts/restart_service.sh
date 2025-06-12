#!/bin/bash
# Restart a service passed as $1
service_name=$1

if systemctl is-active --quiet "$service_name"; then
  echo "Restarting service: $service_name"
  sudo systemctl restart "$service_name"
else
  echo "Service $service_name is not running."
fi
