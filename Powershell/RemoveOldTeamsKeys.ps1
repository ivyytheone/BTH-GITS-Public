##########################################
######## Jamie Bech 2024-09-19 ###########
######### jamie.bech@bth.com #############
######## Remove old teamskeys  ###########
##########################################

# Searchpath to txt file with computer names and logfile.
$computerListFile = "C:\Path\To\computers.txt"
$logFile = "C:\Path\To\LogFile.txt"
$versionToRemove = "1.2.3.4"

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
                Add-Content -Path $logFile -Value "$(Get-Date) - $env:COMPUTERNAME - Tog bort Teams version $versionToRemove från registret."
            }
        }
    }

    if (-not $found) {
        Add-Content -Path $logFile -Value "$(Get-Date) - $env:COMPUTERNAME - Ingen Teams version $versionToRemove hittades."
    }
}

foreach ($computer in $computers) {
    Invoke-Command -ComputerName $computer -ScriptBlock $scriptBlock -ArgumentList $versionToRemove, $logFile
}