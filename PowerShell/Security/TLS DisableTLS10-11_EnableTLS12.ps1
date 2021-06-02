# Disable TLS 1.0 & 1.1. Enable TLS 1.2
$ProtocolList = @("TLS 1.0","TLS 1.1","TLS 1.2")
$ProtocolSubKeyList = @("Client","Server")
$DisabledByDefault = "DisabledByDefault"
$Enabled = "Enabled"
$RegistryPath = "HKLM:\\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\"

ForEach ($Protocol in $ProtocolList) {
    Write-Host " In 1st For loop"
    ForEach ($Key in $ProtocolSubKeyList) {
        $CurrentRegPath = $RegistryPath + $Protocol + "\" + $Key
        Write-Host "Current Registry Path $CurrentRegPath"

        If (!(Test-Path $CurrentRegPath)) {
            Write-Host "Creating the registry"
            New-Item -Path $CurrentRegPath -Force | out-Null
        }
        If ($Protocol -eq "TLS 1.2") {
            Write-Host "Working for TLS 1.2"
            New-ItemProperty -Path $CurrentRegPath -Name $DisabledByDefault -Value "0" -PropertyType DWORD -Force | Out-Null
            New-ItemProperty -Path $CurrentRegPath -Name $Enabled -Value "1" -PropertyType DWORD -Force | Out-Null
        } Else {
            Write-Host "Working for other protocol"
            New-ItemProperty -Path $CurrentRegPath -Name $DisabledByDefault -Value "1" -PropertyType DWORD -Force | Out-Null
            New-ItemProperty -Path $CurrentRegPath -Name $Enabled -Value "0" -PropertyType DWORD -Force | Out-Null
        }
    }
}

# Validate
$Results = Invoke-Command -ComputerName $Servers -ScriptBlock {
    $Object = [pscustomobject]@{
        "ComputerName" = $ENV:Computername
        "PowerShell" = $PSVersionTable.PSVersion
    }

    # Uptime
    $LastBootupTime = Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty LastBootupTime
    $Object | Add-Member -MemberType NoteProperty -Name "BootupTime" -Value $LastBootupTime

    # Protocols
    $ProtocolsRegPath = "HKLM:\system\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\"
    $ProtocolCheck = @(
        "SSL 2.0\Client"
        "SSL 2.0\Server"
        "SSL 3.0\Client"
        "SSL 3.0\Server"
        "TLS 1.0\Client"
        "TLS 1.0\Server"
        "TLS 1.1\Client"
        "TLS 1.1\Server"
        "TLS 1.2\Client"
        "TLS 1.2\Server"
    )
    ForEach ($Entry in $ProtocolCheck) {
        $FullPath = $ProtocolsRegPath + $Entry
        $Enabled = Get-ItemPropertyValue -Path $FullPath -Name "Enabled"
        $DisabledByDefault = Get-ItemPropertyValue -Path $FullPath -Name "DisabledByDefault"
        $Protocol = ($Entry.Replace(" ","").Replace("\"," "))
        If (($Enabled -eq 0) -And ($DisabledByDefault -eq 1)) {
            #Write-Host $Protocol "= Disabled" -ForegroundColor Cyan
            $Object | Add-Member -MemberType NoteProperty -Name $Protocol -Value "Disabled"
        } Else {
            #Write-Host $Protocol "= Enabled" -ForegroundColor Green
            $Object | Add-Member -MemberType NoteProperty -Name $Protocol -Value "Enabled"
        }
    }

    Return $Object
}
$Date = Get-Date -Format yyyyMMddHHMMss
$Results | Export-Csv -Path C:\Temp\TLS\$Date`_TLS_Status.csv -NoTypeInformation 
