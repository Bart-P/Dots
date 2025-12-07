#!/bin/bash
# WARNING! This is AI Generated, not tested, just saved for reference
# This had to be done after and update, after new user creation all Workflows can be accessed without any issue
set -e

# Detect service user
SERVICE_USER=$(systemctl show -p User n8n.service | cut -d= -f2)
[ -z "$SERVICE_USER" ] && SERVICE_USER="root"

# Stop service
systemctl stop n8n

# Reset user (run as service user to hit correct DB)
# !!IMPORTANT!! If running manualy, the "$SERVICE_USER" is just n8n
# So the command is: sudo -u n8n n8n user-management:reset 
sudo -u "$SERVICE_USER" n8n user-management:reset

# Start service
systemctl start n8n
