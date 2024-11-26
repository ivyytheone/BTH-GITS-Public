#!/bin/bash

##########################################
######## Jamie Bech 2024-11-26 ###########
#########  jamie.bech@bth.se  ############
########      BTH-Updates      ###########
##########################################

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if dialog is installed, if not, install it
if ! command -v dialog &> /dev/null; then
    echo "Installing dialog for progress bars..."
    sudo apt-get update
    sudo apt-get install -y dialog
fi

# Function to handle errors
handle_error() {
    echo -e "${RED}Error: $1${NC}"
    exit 1
}

# Progress bar function for package updates
package_update_progress() {
    # Simulate progress
    for i in {1..100}; do
        echo $i
        sleep 0.1
    done
}

# Progress bar function for kernel updates
kernel_update_progress() {
    # Simulate progress
    for i in {1..100}; do
        echo $i
        sleep 0.1
    done
}

# Start the update procedure
echo -e "${GREEN}Starting BTH-update procedure${NC}"

# Run apt-get update and capture both stdout and stderr
update_output=$(sudo apt-get update 2>&1)

# Check the exit status of the update command
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Updates to lists in sources is applied${NC}"
else
    handle_error "Failed to update package lists. Errors: $update_output"
fi

# Continue with package upgrade
echo -e "${GREEN}Continuing update, starting to update packages on this machine${NC}"

# Simulate upgrade to show what packages will be updated
echo "Checking for package updates..."
upgrade_list=$(sudo apt-get -s -u upgrade)

# Ask user about package updates
echo "The following packages will be updated:"
echo "$upgrade_list"
read -p "Do you want to proceed with updates? (y/n): " update_choice

if [[ $update_choice == [Yy] ]]; then
    # Create a progress bar for package updates
    (package_update_progress | dialog --gauge "Updating packages..." 10 70 0) 2>&1

    # Perform actual upgrade
    upgrade_output=$(sudo apt-get -y upgrade 2>&1)
    
    # Clear dialog screen
    clear
    
    # Check upgrade status
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Updates have been applied to packages${NC}"
    else
        echo -e "${RED}Some packages failed to update. Failed packages:${NC}"
        echo -e "${RED}$upgrade_output${NC}"
    fi
else
    echo "Package updates skipped."
fi

# Check for kernel updates
kernel_updates=$(ls /boot/vmlinuz-* | grep -v $(uname -r))

if [ -n "$kernel_updates" ]; then
    echo "There is a kernel update for Linux."
    read -p "Do you want to install the kernel update? (y/n): " kernel_choice

    if [[ $kernel_choice == [Yy] ]]; then
        # Create a progress bar for kernel updates
        (kernel_update_progress | dialog --gauge "Installing kernel update..." 10 70 0) 2>&1

        # Perform kernel update
        sudo apt-get -y install linux-generic
        
        # Clear dialog screen
        clear
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Kernel update installed successfully${NC}"
            echo -e "${GREEN}Have installed the latest packages as well as installed the latest Linux kernel, you should now reboot the machine for the kernel updates to take effect${NC}"
        else
            echo -e "${RED}Failed to install kernel update${NC}"
        fi
    else
        echo -e "${GREEN}Script is finished without applying latest Linux kernel updates${NC}"
    fi
else
    echo "No kernel updates available."
fi

echo -e "${GREEN}Script execution completed${NC}"
