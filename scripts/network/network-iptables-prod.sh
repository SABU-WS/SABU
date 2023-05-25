#!/bin/bash

# RETRIEVE NETWORK INFORMATION
interface=$(jq '.network | .interface' /SABU/config/config.json  | tr -d '"')
address=$(jq '.network | .ip' /SABU/config/config.json  | tr -d '"')
netmask=$(jq '.network | .netmask' /SABU/config/config.json  | tr -d '"')
nameserver1=$(jq '.network | .dns1' /SABU/config/config.json  | tr -d '"')
nameserver2=$(jq '.network | .dns2' /SABU/config/config.json  | tr -d '"')

# CALCULATE NETWORK
network=$(ipcalc $address/$netmask | grep "Network" | cut -d' ' -f4)

# FLUSH TABLE
iptables -F

# INPUT RULES
## acces_ssh
iptables -A INPUT -p tcp -i $interface --src $network --dst $address --dport 22 -j ACCEPT
## connexion_http
iptables -A INPUT -p tcp -i $interface --src $network --dst $address --dport 80 -j ACCEPT
## connexion_https
iptables -A INPUT -p tcp -i $interface --src $network --dst $address --dport 443 -j ACCEPT
## drop_all
iptables -A INPUT -i $interface --src 0.0.0.0/0 --dst $address -j DROP

# OUTPUT RULES
## acces_ssh
iptables -A OUTPUT -p tcp --src $address --dst $network -j ACCEPT
## connexion_http
iptables -A OUTPUT -p tcp --src $address --dst 0.0.0.0/0 --dport 80 -j ACCEPT
## connexion_https
iptables -A OUTPUT -p tcp --src $address --dst 0.0.0.0/0 --dport 443 -j ACCEPT
## drop_all
iptables -A OUTPUT --src $address --dst 0.0.0.0/0 -j DROP

# SAVE 
iptables-save > /etc/iptables/rules.v4

# LOG ACTION
date=$(date +"[%Y-%m-%d %H:%M:%S]")
echo "$date [NETWORK][Iptables] Rule 'iptables-prod' enabled" >> /sabu/logs/network.log

# --- Script By SABU --- #
