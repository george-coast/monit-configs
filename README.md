# Monit Configs Repository

This repository contains example Monit configuration files and helper scripts.

## Structure

- `services/`: Monit service config files (e.g., ssh, nginx, mysql)
- `scripts/`: Helper scripts to notify admin and restart services
- `install.sh`: Example installation script to deploy configs

## Usage

1. Copy service config files to your monit directory (usually `/etc/monit.d/`)
2. Reload or restart monit to apply new configs
3. Use scripts for custom service control or notifications
