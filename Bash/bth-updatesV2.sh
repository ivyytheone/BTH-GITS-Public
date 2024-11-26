#!/bin/bash

##########################################
######## Jamie Bech 2024-11-26 ###########
#########  jamie.bech@bth.se  ############
########     BTH-UpdatesV2     ###########
##########################################


# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Progress bar function
show_progress() {
    local duration=${1}
    local message=${2}
    local force_complete=${3:-false}
    local progress=0

    if [ "$force_complete" = true ]; then
        # If force complete, quickly jump to 100%
        printf "\r${GREEN}${message} Complete!                               \n${NC}"
        return
    fi

    while [ $progress -le 100 ]; do
        # Create progress bar
        printf "\r${YELLOW}${message} [%-50s] %d%%" $(printf "#%.0s" $(seq 1 $((progress/2))))  $progress
        
        # Increment progress
        progress=$((progress+1))
        
        # Simulate work (replace with actual update process in real scenario)
        sleep ${duration:-0.1}
    done

    printf "\r${GREEN}${message} Complete!                               \n${NC}"
}

# Detect machine architecture
detect_architecture() {
    local arch=$(uname -m)
    
    case "$arch" in
        x86_64)
            echo "linux-image-amd64"
            ;;
        i686|i386)
            echo "linux-image-686-pae"
            ;;
        *)
            echo "unsupported"
            ;;
    esac
}

# Start the update procedure
echo -e "${GREEN}Starting BTH-update procedure${NC}"

# Detect kernel package
KERNEL_PACKAGE=$(detect_architecture)

# Check if architecture is supported
if [ "$KERNEL_PACKAGE" == "unsupported" ]; then
    echo -e "${RED}Unsupported system architecture. Cannot determine kernel update package.${NC}"
    exit 1
fi

# Run apt-get update and capture both stdout and stderr
update_output=$(sudo apt-get update 2>&1)

# Check the exit status of the update command
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Updates to lists in sources is applied${NC}"
else
    echo -e "${RED}Failed to update package lists. Errors: $update_output${NC}"
    exit 1
fi

# Continue with package upgrade
echo -e "${GREEN}Continuing update, starting to update packages on this machine${NC}"

# Check for available package updates
upgrade_list=$(sudo apt-get -s -u upgrade)

# Determine if there are any packages to update
if [ -z "$upgrade_list" ]; then
    echo "No packages need to be updated."
    # Force complete progress bar
    (show_progress 0.05 "Updating Packages" true) &
else
    # Ask user about package updates
    echo "The following packages will be updated:"
    echo "$upgrade_list"
    read -p "Do you want to proceed with updates? (y/n): " update_choice

    if [[ $update_choice == [Yy] ]]; then
        # Show progress for package updates
        (show_progress 0.05 "Updating Packages") &
        upgrade_pid=$!

        # Perform actual upgrade
        upgrade_output=$(sudo apt-get -y upgrade 2>&1)
        upgrade_status=$?

        # Kill the progress bar
        kill $upgrade_pid 2>/dev/null
        wait $upgrade_pid 2>/dev/null

        # Check upgrade status
        if [ $upgrade_status -eq 0 ]; then
            echo -e "${GREEN}Updates have been applied to packages${NC}"
        else
            echo -e "${RED}Some packages failed to update. Failed packages:${NC}"
            echo -e "${RED}$upgrade_output${NC}"
        fi
    else
        echo "Package updates skipped."
    fi
fi

# Check for kernel updates
kernel_updates=$(ls /boot/vmlinuz-* | grep -v $(uname -r))

if [ -n "$kernel_updates" ]; then
    echo "There is a kernel update for Linux."
    echo "Detected kernel package: ${KERNEL_PACKAGE}"
    read -p "Do you want to install the kernel update? (y/n): " kernel_choice

    if [[ $kernel_choice == [Yy] ]]; then
        # Show progress for kernel updates
        (show_progress 0.1 "Installing Kernel Update") &
        kernel_pid=$!

        # Perform kernel update
        kernel_output=$(sudo apt-get -y install ${KERNEL_PACKAGE} 2>&1)
        kernel_status=$?

        # Kill the progress bar
        kill $kernel_pid 2>/dev/null
        wait $kernel_pid 2>/dev/null

        # Check kernel update status
        if [ $kernel_status -eq 0 ]; then
            echo -e "${GREEN}Kernel update installed successfully${NC}"
            echo -e "${GREEN}Have installed the latest packages as well as installed the latest Linux kernel, you should now reboot the machine for the kernel updates to take effect${NC}"
        else
            echo -e "${RED}Failed to install kernel update${NC}"
            echo -e "${RED}$kernel_output${NC}"
        fi
    else
        echo -e "${GREEN}Script is finished without applying latest Linux kernel updates${NC}"
    fi
else
    echo "No kernel updates available."
    # Force complete progress bar
    (show_progress 0.1 "Installing Kernel Update" true) &
fi

# Cleanup commands
echo -e "${YELLOW}Starting system cleanup...${NC}"

# Run apt autoremove
echo -e "${GREEN}Removing unnecessary packages...${NC}"
(show_progress 0.05 "Auto Remove") &
cleanup_pid=$!

sudo apt autoremove -y

kill $cleanup_pid 2>/dev/null
wait $cleanup_pid 2>/dev/null

# Remove residual config files
echo -e "${GREEN}Removing residual configuration files...${NC}"
(show_progress 0.05 "Purge Residual Configs") &
purge_pid=$!

for a in `dpkg -l | grep  ^rc | awk ' { print $2 }' `; do 
    sudo apt-get -y purge $a
done

kill $purge_pid 2>/dev/null
wait $purge_pid 2>/dev/null

echo -e "${GREEN}Cleanup completed successfully${NC}"
echo -e "${GREEN}Script execution completed${NC}"