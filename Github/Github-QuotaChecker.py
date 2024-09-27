##########################################
######## Jamie Bech 2024-08-30 ###########
#########  jamie.bech@bth.se  ############
########    Git-QuotaChecker   ###########
##########################################
#QuotaChecker.py

import requests

# GitHub API token
token = 'YOUR_GITHUB_TOKEN'
headers = {'Authorization': f'token {token}'}

# Repository information
owner = 'REPO_OWNER'
repo = 'REPO_NAME'

# Fetch repository details
repo_url = f'https://api.github.com/repos/{owner}/{repo}'
response = requests.get(repo_url, headers=headers)
repo_data = response.json()

# Print repository size in MB
repo_size = repo_data['size'] / 1024
print(f'Repository size: {repo_size} MB')
