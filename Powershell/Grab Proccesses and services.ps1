##########################################
######## Jamie Bech 2024-08-16 ###########
#########  jamie.bech@bth.se  ############
######## Grab Process &Service ###########
##########################################

# Define the list of computers
$computers = @("ComputerName1", "ComputerName2")

# Loop through each computer
foreach ($computer in $computers) {
    Write-Output "Fetching data from ${computer}..."

    # Get services
    $services = Get-Service -ComputerName $computer | Select-Object Name, DisplayName, Status, StartType

    # Get processes
    $processes = Get-Process -ComputerName $computer | Select-Object Name, Id, CPU, StartTime, Path, Description 

    # Output results
    Write-Output "Services on ${computer}:"
    $services | Format-Table -AutoSize

    Write-Output "Processes on ${computer}:"
    $processes | Format-Table -AutoSize

    Write-Output "----------------------------------------"
}