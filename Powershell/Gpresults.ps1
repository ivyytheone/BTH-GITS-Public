##########################################
######## Jamie Bech 2024-08-13 ###########
######### jamie.bech@bth.com #############
########    Grab Gpresults     ###########
##########################################

# Define path to file with computernames
$computerListFile = "C:\Users\jbc\PS\computer_list.txt"

# Grab computernames from file
$computerNames = Get-Content $computerListFile

# Path to save reportfiles
$localReportPath = "C:\Rapporter\Gpresults"

# Credentials popup
$credentials = Get-Credential

# Loopa through computers
foreach ($computer in $computerNames) {
    Write-Host "Fetching Group Policy results for $computer..."

    # Create report of GPresult and save as HTML-file on remote computer
    $remoteReportPath = "\\$computer\\c$\\temp\\gpresult_$computer.html"
    Invoke-Command -ComputerName $computer -Credential $credentials -ScriptBlock {
        gpresult /h c:\temp\gpresult_$env:COMPUTERNAME.html
    }

    # Copy report from remote computer to local computer(running)
    Copy-Item -Path $remoteReportPath -Destination $localReportPath -FromSession (New-PSSession -ComputerName $computer -Credential $credentials)

    Write-Host "The report for $computer have been saved to $localReportPath"
}

# Print results
Write-Host "All reports have been fetched."