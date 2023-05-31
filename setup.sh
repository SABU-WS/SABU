#!/bin/bash

# RETRIEVE NETWORK IP
ipaddress=$(ip -br a | tail -n 1 | awk '{print $3}' | cut -d '/' -f 1)

# Setup workspace
mkdir /sabu
cp -r * /sabu

# Install packages 
apt install sudo python3 python3-pip jq debconf-utils -y

sleep 3

# Adduser/permission SABU
adduser sabu --shell=/bin/false --no-create-home
echo "sabu ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
chown -R sabu:sabu /sabu
chmod -R +x /sabu/scripts
chmod -R +x /sabu/config

# Install python requirements
pip3 install -r ./gui/requirements.txt

sleep 3

# Start gui
mv ./service/sabu.service /etc/systemd/system/
rm -r /sabu/service
systemctl daemon-reload
systemctl start sabu.service
systemctl enable sabu.service

# End
echo "Setup completed !"
echo "Open browser and visit : http://$ipaddress:8888/setup"
echo "Password : P4\$\$w0rdF0r54Bu5t4t10N"

# Remove tmp folder
rm -rf ../SABU

# LOG ACTION
date=$(date +"[%Y-%m-%d %H:%M:%S]")
echo "$date [SABU] The setup script has been executed successfully" >> /sabu/logs/sabu.log

# --- Script By SABU --- #
