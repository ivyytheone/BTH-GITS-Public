##########################################
######## Jamie Bech 2024-08-25 ###########
######### jamie.bech@bth.com #############
########     PackageCheck      ###########
##########################################

#!/bin/bash

# INC serverlist
#source ./servers_list.sh  JBC-removed to make it variable
servers=("serverip1" "serverip2" "serverip3")


# Ask about packagename
read -p "Which packages? (separate multiple packages with commas): " package_names

# Convert comma-separated list to array
IFS=',' read -r -a package_array <<< "$package_names"

# Loop through each server and check the package versions
for server in "${servers[@]}"
do
    echo "Checking packages on $server"
    for package_name in "${package_array[@]}"
    do
        package_name=$(echo $package_name | xargs) # Remove any extra spaces
        echo "Checking for $package_name on $server"
        ssh user@$server "dpkg -s $package_name | grep 'Version'"
    done
done
