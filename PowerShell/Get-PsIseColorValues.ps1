# https://devblogs.microsoft.com/scripting/exploring-the-windows-powershell-ise-color-objects
# https://devblogs.microsoft.com/scripting/change-colors-used-by-the-windows-powershell-ise

#
$psISE | Format-List *
CurrentPowerShellTab : Microsoft.PowerShell.Host.ISE.PowerShellTab
CurrentFile : Microsoft.PowerShell.Host.ISE.ISEFile
Options : Microsoft.PowerShell.Host.ISE.ISEOptions
PowerShellTabs : {PowerShell 1}

#
$psISE.Options

#
$psISE.Options.TokenColors

#
[windows.media.colors] | Get-Member -Static -MemberType property

#
$psISE.Options.OutputPaneTextBackgroundColor = ([windows.media.colors]::$($_.name)).ToString()

#
[windows.media.colors]::aqua 

#
"$([windows.media.colors]::aqua)"

#
Get-PsIseColorValues.ps1

[windows.media.colors] | Get-Member -Static -MemberType property | 
ForEach-Object { 
$psISE.Options.OutputPaneTextBackgroundColor = `
([windows.media.colors]::$($_.name)).tostring() 
"$($_.name) `t $([windows.media.colors]::$($_.name))"
}
