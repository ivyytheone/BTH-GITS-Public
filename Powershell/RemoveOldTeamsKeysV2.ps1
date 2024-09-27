##########################################
######## Jamie Bech 2024-09-27 ###########
######### jamie.bech@bth.se  #############
########  Remove teamskeys V2  ###########
##########################################

# Searchpath to txt file with computer names and logfile.
$computerListFile = "C:\temp\TeamsKeys\computers.txt"
$logFile = "C:\temp\TeamsKeys\LogFile.txt"
$versionToRemove = "1.2.0.24753"

# Read computernames from txt
$computers = Get-Content -Path $computerListFile

$scriptBlock = {
    param ($versionToRemove, $logFile)
    $registryPaths = @(
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Teams",
        "HKU:\*\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Teams"
    )
    $found = $false

    foreach ($registryPath in $registryPaths) {
        $subKeys = Get-ChildItem -Path $registryPath -ErrorAction SilentlyContinue
        foreach ($subKey in $subKeys) {
            $version = (Get-ItemProperty -Path $subKey.PSPath).DisplayVersion
            if ($version -eq $versionToRemove) {
                Remove-Item -Path $subKey.PSPath -Recurse
                $found = $true
                $logMessage = "$(Get-Date) - $env:COMPUTERNAME - Tog bort Teams version $versionToRemove från registret."
                Add-Content -Path $logFile -Value $logMessage
                Write-Output $logMessage
            }
        }
    }

    if (-not $found) {
        $logMessage = "$(Get-Date) - $env:COMPUTERNAME - Ingen Teams version $versionToRemove hittades."
        Add-Content -Path $logFile -Value $logMessage
        Write-Output $logMessage
    }
}

foreach ($computer in $computers) {
    # Ping the computer to check if it's reachable
    if (Test-Connection -ComputerName $computer -Count 2 -Quiet) {
        $logMessage = "$(Get-Date) - $computer - Datorn kan nås via ping."
        Add-Content -Path $logFile -Value $logMessage
        Write-Output $logMessage
        Invoke-Command -ComputerName $computer -ScriptBlock $scriptBlock -ArgumentList $versionToRemove, $logFile
    }
    else {
        # Log the failure to reach the computer
        $logMessage = "$(Get-Date) - $computer - Kunde inte nå datorn via ping."
        Add-Content -Path $logFile -Value $logMessage
        Write-Output $logMessage
    }
}