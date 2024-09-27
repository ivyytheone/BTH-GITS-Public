##########################################
######## Jamie Bech 2024-08-30 ###########
#########  jamie.bech@bth.se  ############
########    Github-Backups     ###########
##########################################
#Backing up repos.py

import requests
import os

# GitHub API token
token = 'YOUR_GITHUB_TOKEN'
headers = {'Authorization': f'token {token}'}

# Repository information
owner = 'REPO_OWNER'
repo = 'REPO_NAME'

# Directory to save backups
backup_dir = 'backups'

# Create backup directory if it doesn't exist
os.makedirs(backup_dir, exist_ok=True)

# Fetch and save pull requests
pulls_url = f'https://api.github.com/repos/{owner}/{repo}/pulls'
pulls = requests.get(pulls_url, headers=headers).json()
with open(os.path.join(backup_dir, 'pull_requests.json'), 'w') as f:
    json.dump(pulls, f)

# Fetch and save commits
commits_url = f'https://api.github.com/repos/{owner}/{repo}/commits'
commits = requests.get(commits_url, headers=headers).json()
with open(os.path.join(backup_dir, 'commits.json'), 'w') as f:
    json.dump(commits, f)
