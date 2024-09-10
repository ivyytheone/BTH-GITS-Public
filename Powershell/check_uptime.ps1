##########################################
######## Jamie Bech 2024-09-10 ###########
######### jamie.bech@bth.com #############
########      Check uptime     ###########
##########################################

function TimeSpanAsString([TimeSpan]$uptime) {
    [int]$days = $uptime.Days
    [int]$hours = $days * 24 + $uptime.Hours
    if ($days -gt 2) {
        return "$days days"
    }
    elseif ($hours -gt 1) {
        return "$hours hours"
    }
    else {
        return "$($uptime.Minutes)min"
    }
}

function Test-RegistryValue {
    param([parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]$Path, [parameter(Mandatory = $true)] [ValidateNotNullOrEmpty()]$Value)
    try {
        Get-ItemProperty -Path $Path -Name $Value -EA Stop
        return $true
    }
    catch {
        return $false
    }
}

try {
    [system.threading.thread]::currentthread.currentculture = [system.globalization.cultureinfo]"en-US"
    if ($IsLinux) {
        $lastBootTime = (Get-Uptime -since)
        $uptime = (Get-Uptime)
    }
    else {
        $lastBootTime = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime 
        $uptime = New-TimeSpan -Start $lastBootTime -End (Get-Date)
    }
    $status = "✅"
    $pending = "No pending reboot"
    if ($IsLinux) {
        if (Test-Path "/var/run/reboot-required") {
            $status = "⚠️ "
            $pending = "Pending reboot (found: /var/run/reboot-required)"
        }
    }
    else {
        $reason = ""
        if (Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired") {
            $reason += ", ...\Auto Update\RebootRequired"
        }
        if (Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\PostRebootReporting") {
            $reason += ", ...\Auto Update\PostRebootReporting"
        }
        if (Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending") {
            $reason += ", ...\Component Based Servicing\RebootPending"
        }
        if (Test-Path -Path "HKLM:\SOFTWARE\Microsoft\ServerManager\CurrentRebootAttempts") {
            $reason += ", ...\ServerManager\CurrentRebootAttempts"
        }
        if (Test-RegistryValue -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing" -Value "RebootInProgress") {
            $reason += ", ...\CurrentVersion\Component Based Servicing with 'RebootInProgress'"
        }
        if (Test-RegistryValue -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing" -Value "PackagesPending") {
            $reason += ", '...\CurrentVersion\Component Based Servicing' with 'PackagesPending'"
        }
        if (Test-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Value "PendingFileRenameOperations2") {
            $reason += ", '...\CurrentControlSet\Control\Session Manager' with 'PendingFileRenameOperations2'"
        }
        if (Test-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" -Value "DVDRebootSignal") {
            $reason += ", '...\Windows\CurrentVersion\RunOnce' with 'DVDRebootSignal'"
        }
        if (Test-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon" -Value "JoinDomain") {
            $reason += ", '...\CurrentControlSet\Services\Netlogon' with 'JoinDomain'"
        }
        if (Test-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon" -Value "AvoidSpnSet") {
            $reason += ", '...\CurrentControlSet\Services\Netlogon' with 'AvoidSpnSet'"
        }
        if ($reason -ne "") {
            $status = "⚠️ "
            $pending = "Pending reboot (registry got $($reason.substring(2)))"
        }
    }
    Write-Host "$status $(hostname) is up for $(TimeSpanAsString $uptime) since $($lastBootTime.ToShortDateString()) - $pending"
    exit 0 # success
}
catch {
    "⚠️ Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
    exit 1
}