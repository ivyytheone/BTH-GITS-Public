##########################################
######## Jamie Bech 2024-08-30 ###########
######### jamie.bech@bth.com #############
########    Github-Backups     ###########
##########################################
#Backing up repos.sh

#!/bin/bash

# GitHub repository information
OWNER="REPO_OWNER"
REPO="REPO_NAME"
BACKUP_DIR="backups"

# Create backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

# Clone the repository
gh repo clone $OWNER/$REPO $BACKUP_DIR/$REPO

# Compress the backup
tar -czf $BACKUP_DIR/$REPO.tar.gz -C $BACKUP_DIR $REPO

# Remove the cloned repository
rm -rf $BACKUP_DIR/$REPO
