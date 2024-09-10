##########################################
######## Jamie Bech 2024-09-10 ###########
######### jamie.bech@bth.com #############
######## Check active process  ###########
##########################################
#Local computer only.
try {
    Get-Process | Format-Table -Property Id, @{Label = "CPU(s)"; Expression = { $_.CPU.ToString("N") + "%" }; Alignment = "Right" }, ProcessName -AutoSize
    exit 0 # success
}
catch {
    "⚠️ Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
    exit 1
}