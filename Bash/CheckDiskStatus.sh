##########################################
######## Jamie Bech 2024-08-25 ###########
#########  jamie.bech@bth.se  ############
########     DiskChecking      ###########
##########################################

#!/bin/bash

# List of servers
servers=("server1" "server2" "server3")

# Loop through each server
for server in "${servers[@]}"
do
  echo "Checking disk status on $server"
  ssh user@$server 'mount | grep " ro," | awk -v server="$server" '\''{print server ": " $0}'\'''
  echo ""
done
