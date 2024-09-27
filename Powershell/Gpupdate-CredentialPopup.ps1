##########################################
######## Jamie Bech 2024-08-13 ###########
#########  jamie.bech@bth.se  ############
########    Force Gpupdate     ###########
##########################################
#Generating a GPresult file and copying it from remote to local computer with name "gpresult_$computername.html"
#Differense here is that a credentialspopupp will come insted of saving credentials to files.

# Define path to file with computernames
$computerListFile = "C:\Users\jbc\PS\computer_list.txt"

# Grab computernames from file
$computerNames = Get-Content $computerListFile

# Credentials popup
$credentials = Get-Credential

# Loopa through computers
foreach ($computer in $computerNames) {
    Write-Host "Starting gpupdate on $computer..."

    # Start Gpupdate on client and wait for end and results.
    $job = Invoke-Command -ComputerName s $computer -Credential $credential -ScriptBlock {
        gpupdate /force
    } -AsJob

    # Wait for results before continueing 
    $job | Wait-Job

    Write-Host "Group Policy update on $computer is complete."
}

# Print results
Write-Host "All computers have been updated."