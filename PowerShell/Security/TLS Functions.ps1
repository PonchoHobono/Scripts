# Code
SERVER1
SERVER2
$Computers = Get-Clipboard
Get-SSLTLSProtocol -ComputerName $Computers
#Disable-TLS10 -ComputerName $Computers


# Functions

function Get-SSLTLSProtocol {
<#
.SYNOPSIS
    Gets the current state of SSL & TLS protocols.
    
.DESCRIPTION
    
.PARAMETER ComputerName
    Specifies the computers for which this cmdlet gets insecure service permissions. The default is the local computer.
            
    Type the NetBIOS name, an IP address, or a fully qualified domain name (FQDN) of one or more computers.
    To specify the local computer, type the computer name, a dot (.), or localhost. You can also not use the
    parameter at all & it will run locally.
  
.EXAMPLE
    Get-SSLTLSProtocol
      
.NOTES
    Created by: Patrick Hoban
    
.LINK 

#>

    [CmdletBinding(
        DefaultParameterSetName="Default"
    )]
    Param (
        [Parameter(ParameterSetName="Default",Mandatory=$false,ValueFromPipeline=$false,Position=0)]
            [String[]]$ComputerName = $env:COMPUTERNAME
    )

    begin {
        $ScriptBlock =  {

            $Object = [pscustomobject]@{
                "ComputerName" = $ENV:Computername
                "OS" = (Get-WmiObject -Class Win32_OperatingSystem).Caption.Trim()
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
                if (Test-Path -Path $FullPath) {
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
                } else {
                    Write-host "[$env:COMPUTERNAME][Error] $FullPath" -ForegroundColor Red
                    $Protocol = ($Entry.Replace(" ","").Replace("\"," "))
                    $Object | Add-Member -MemberType NoteProperty -Name $Protocol -Value "MISSING"
                }
            }

            Return $Object
                
            } # End of Scriptblock
    }
    process {
        try {
            if ($ComputerName -eq $env:COMPUTERNAME) {
                & $ScriptBlock
            } else {
                Invoke-Command -ComputerName $ComputerName -ScriptBlock $ScriptBlock -ArgumentList $PSBoundParameters
            }
        }
        catch {
            Write-Error -Message "Error: $($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)"
        }
    }
    end {
    }
}


function Disable-SSL30 {
<#
.SYNOPSIS
    Disables SSL 3.0
    
.DESCRIPTION
    
.PARAMETER ComputerName
    Specifies the computers for which this cmdlet gets insecure service permissions. The default is the local computer.
            
    Type the NetBIOS name, an IP address, or a fully qualified domain name (FQDN) of one or more computers.
    To specify the local computer, type the computer name, a dot (.), or localhost. You can also not use the
    parameter at all & it will run locally.
  
.EXAMPLE
    Disable-SSL30
      
.NOTES
    Created by: Patrick Hoban
    
.LINK 

#>

    [CmdletBinding(
        DefaultParameterSetName="Default"
    )]
    Param (
        [Parameter(ParameterSetName="Default",Mandatory=$false,ValueFromPipeline=$false,Position=0)]
            [String[]]$ComputerName = $env:COMPUTERNAME
    )
    
    begin {
        $ScriptBlock =  {

            if (!(Test-Path -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Client')) {
                New-Item -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0' -Name 'Client' | Out-Null
            }
            if (!(Test-Path -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server')) {
                New-Item -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0' -Name 'Server' | Out-Null
            }
            New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Client' -Name 'DisabledByDefault' -Value '1' -PropertyType DWORD -Force | Out-Null
            New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Client' -Name 'Enabled' -Value '0' -PropertyType DWORD -Force | Out-Null
            New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server' -Name 'DisabledByDefault' -Value '1' -PropertyType DWORD -Force | Out-Null
            New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server' -Name 'Enabled' -Value '0' -PropertyType DWORD -Force | Out-Null
        
        } # End of Scriptblock
    }
    process {
        try {
            if ($ComputerName -eq $env:COMPUTERNAME) {
                & $ScriptBlock
            } else {
                Invoke-Command -ComputerName $ComputerName -ScriptBlock $ScriptBlock -ArgumentList $PSBoundParameters
            }
        }
        catch {
            Write-Error -Message "Error: $($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)"
        }
    }
    end {
    }
}


function Disable-TLS10 {
<#
.SYNOPSIS
    Disables TLS 1.0.
    
.DESCRIPTION
    
.PARAMETER ComputerName
    Specifies the computers for which this cmdlet gets insecure service permissions. The default is the local computer.
            
    Type the NetBIOS name, an IP address, or a fully qualified domain name (FQDN) of one or more computers.
    To specify the local computer, type the computer name, a dot (.), or localhost. You can also not use the
    parameter at all & it will run locally.
  
.EXAMPLE
    Disable-TLS10 -ComputerName SERVER1

    This will disable TLS 1.0 on SERVER1 by setting registry keys. If the keys don't already exist they will be created.
      
.NOTES
    Created by: Patrick Hoban
    
.LINK 

#>

    [CmdletBinding(
        DefaultParameterSetName="Default"
    )]
    Param (
        [Parameter(ParameterSetName="Default",Mandatory=$false,ValueFromPipeline=$false,Position=0)]
            [String[]]$ComputerName = $env:COMPUTERNAME
    )
    
    begin {
        $ScriptBlock =  {

            if (!(Test-Path -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client')) {
                New-Item -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0' -Name 'Client' | Out-Null
            }
            if (!(Test-Path -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server')) {
                New-Item -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0' -Name 'Server' | Out-Null
            }
            New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client' -Name 'DisabledByDefault' -Value '1' -PropertyType DWORD -Force | Out-Null
            New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client' -Name 'Enabled' -Value '0' -PropertyType DWORD -Force | Out-Null
            New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server' -Name 'DisabledByDefault' -Value '1' -PropertyType DWORD -Force | Out-Null
            New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server' -Name 'Enabled' -Value '0' -PropertyType DWORD -Force | Out-Null
        
        } # End of Scriptblock
    }
    process {
        try {
            if ($ComputerName -eq $env:COMPUTERNAME) {
                & $ScriptBlock
            } else {
                Invoke-Command -ComputerName $ComputerName -ScriptBlock $ScriptBlock -ArgumentList $PSBoundParameters
            }
        }
        catch {
            Write-Error -Message "Error: $($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)"
        }
    }
    end {
    }
}


function Disable-TLS11 {
<#
.SYNOPSIS
    Disables TLS 1.1.
    
.DESCRIPTION
    
.PARAMETER ComputerName
    Specifies the computers for which this cmdlet gets insecure service permissions. The default is the local computer.
            
    Type the NetBIOS name, an IP address, or a fully qualified domain name (FQDN) of one or more computers.
    To specify the local computer, type the computer name, a dot (.), or localhost. You can also not use the
    parameter at all & it will run locally.
  
.EXAMPLE
    Disable-TLS11
      
.NOTES
    Created by: Patrick Hoban
    
.LINK 

#>

    [CmdletBinding(
        DefaultParameterSetName="Default"
    )]
    Param (
        [Parameter(ParameterSetName="Default",Mandatory=$false,ValueFromPipeline=$false,Position=0)]
            [String[]]$ComputerName = $env:COMPUTERNAME
    )
    
    begin {
        $ScriptBlock =  {

            if (!(Test-Path -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client')) {
                New-Item -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1' -Name 'Client' | Out-Null
            }
            if (!(Test-Path -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server')) {
                New-Item -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1' -Name 'Server' | Out-Null
            }
            New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client' -Name 'DisabledByDefault' -Value '1' -PropertyType DWORD -Force | Out-Null
            New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client' -Name 'Enabled' -Value '0' -PropertyType DWORD -Force | Out-Null
            New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server' -Name 'DisabledByDefault' -Value '1' -PropertyType DWORD -Force | Out-Null
            New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server' -Name 'Enabled' -Value '0' -PropertyType DWORD -Force | Out-Null
        
        } # End of Scriptblock
    }
    process {
        try {
            if ($ComputerName -eq $env:COMPUTERNAME) {
                & $ScriptBlock
            } else {
                Invoke-Command -ComputerName $ComputerName -ScriptBlock $ScriptBlock -ArgumentList $PSBoundParameters
            }
        }
        catch {
            Write-Error -Message "Error: $($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)"
        }
    }
    end {
    }
}


function Enable-SSL30 {
<#
.SYNOPSIS
    Enables SSL 3.0.
    
.DESCRIPTION
    
.PARAMETER ComputerName
    Specifies the computers for which this cmdlet gets insecure service permissions. The default is the local computer.
            
    Type the NetBIOS name, an IP address, or a fully qualified domain name (FQDN) of one or more computers.
    To specify the local computer, type the computer name, a dot (.), or localhost. You can also not use the
    parameter at all & it will run locally.
  
.EXAMPLE
    Enable-SSL30
      
.NOTES
    Created by: Patrick Hoban
    
.LINK 

#>

    [CmdletBinding(
        DefaultParameterSetName="Default"
    )]
    Param (
        [Parameter(ParameterSetName="Default",Mandatory=$false,ValueFromPipeline=$false,Position=0)]
            [String[]]$ComputerName = $env:COMPUTERNAME
    )
    
    begin {
        $ScriptBlock =  {

            if (!(Test-Path -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Client')) {
                New-Item -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0' -Name 'Client' | Out-Null
            }
            if (!(Test-Path -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server')) {
                New-Item -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0' -Name 'Server' | Out-Null
            }
            New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Client' -Name 'DisabledByDefault' -Value '0' -PropertyType DWORD -Force | Out-Null
            New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Client' -Name 'Enabled' -Value '1' -PropertyType DWORD -Force | Out-Null
            New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server' -Name 'DisabledByDefault' -Value '0' -PropertyType DWORD -Force | Out-Null
            New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server' -Name 'Enabled' -Value '1' -PropertyType DWORD -Force | Out-Null
        
        } # End of Scriptblock
    }
    process {
        try {
            if ($ComputerName -eq $env:COMPUTERNAME) {
                & $ScriptBlock
            } else {
                Invoke-Command -ComputerName $ComputerName -ScriptBlock $ScriptBlock -ArgumentList $PSBoundParameters
            }
        }
        catch {
            Write-Error -Message "Error: $($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)"
        }
    }
    end {
    }
}


function Enable-TLS10 {
<#
.SYNOPSIS
    Enables TLS 1.0.
    
.DESCRIPTION
    
.PARAMETER ComputerName
    Specifies the computers for which this cmdlet gets insecure service permissions. The default is the local computer.
            
    Type the NetBIOS name, an IP address, or a fully qualified domain name (FQDN) of one or more computers.
    To specify the local computer, type the computer name, a dot (.), or localhost. You can also not use the
    parameter at all & it will run locally.
  
.EXAMPLE
    Disable-TLS10
      
.NOTES
    Created by: Patrick Hoban
    
.LINK 

#>

    [CmdletBinding(
        DefaultParameterSetName="Default"
    )]
    Param (
        [Parameter(ParameterSetName="Default",Mandatory=$false,ValueFromPipeline=$false,Position=0)]
            [String[]]$ComputerName = $env:COMPUTERNAME
    )
    
    begin {
        $ScriptBlock =  {

            if (!(Test-Path -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client')) {
                New-Item -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0' -Name 'Client' | Out-Null
            }
            if (!(Test-Path -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server')) {
                New-Item -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0' -Name 'Server' | Out-Null
            }
            New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client' -Name 'DisabledByDefault' -Value '0' -PropertyType DWORD -Force | Out-Null
            New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client' -Name 'Enabled' -Value '1' -PropertyType DWORD -Force | Out-Null
            New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server' -Name 'DisabledByDefault' -Value '0' -PropertyType DWORD -Force | Out-Null
            New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server' -Name 'Enabled' -Value '1' -PropertyType DWORD -Force | Out-Null
        
        } # End of Scriptblock
    }
    process {
        try {
            if ($ComputerName -eq $env:COMPUTERNAME) {
                & $ScriptBlock
            } else {
                Invoke-Command -ComputerName $ComputerName -ScriptBlock $ScriptBlock -ArgumentList $PSBoundParameters
            }
        }
        catch {
            Write-Error -Message "Error: $($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)"
        }
    }
    end {
    }
}


function Enable-TLS11 {
<#
.SYNOPSIS
    Enables TLS 1.1.
    
.DESCRIPTION
    
.PARAMETER ComputerName
    Specifies the computers for which this cmdlet gets insecure service permissions. The default is the local computer.
            
    Type the NetBIOS name, an IP address, or a fully qualified domain name (FQDN) of one or more computers.
    To specify the local computer, type the computer name, a dot (.), or localhost. You can also not use the
    parameter at all & it will run locally.
  
.EXAMPLE
    Disable-TLS11
      
.NOTES
    Created by: Patrick Hoban
    
.LINK 

#>

    [CmdletBinding(
        DefaultParameterSetName="Default"
    )]
    Param (
        [Parameter(ParameterSetName="Default",Mandatory=$false,ValueFromPipeline=$false,Position=0)]
            [String[]]$ComputerName = $env:COMPUTERNAME
    )
    
    begin {
        $ScriptBlock =  {

            if (!(Test-Path -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client')) {
                New-Item -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1' -Name 'Client' | Out-Null
            }
            if (!(Test-Path -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server')) {
                New-Item -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1' -Name 'Server' | Out-Null
            }
            New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client' -Name 'DisabledByDefault' -Value '0' -PropertyType DWORD -Force | Out-Null
            New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client' -Name 'Enabled' -Value '1' -PropertyType DWORD -Force | Out-Null
            New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server' -Name 'DisabledByDefault' -Value '0' -PropertyType DWORD -Force | Out-Null
            New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server' -Name 'Enabled' -Value '1' -PropertyType DWORD -Force | Out-Null
        
        } # End of Scriptblock
    }
    process {
        try {
            if ($ComputerName -eq $env:COMPUTERNAME) {
                & $ScriptBlock
            } else {
                Invoke-Command -ComputerName $ComputerName -ScriptBlock $ScriptBlock -ArgumentList $PSBoundParameters
            }
        }
        catch {
            Write-Error -Message "Error: $($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)"
        }
    }
    end {
    }
}


# Add computer accounts to a group
$TLS10 = 'TLS1.0_PRD'
$TLS11 = 'TLS1.1_PRD'
Get-ADGroup -Identity $TLS10
Get-ADGroup -Identity $TLS11
$TLS10Members = Get-ADGroupMember -Identity $TLS10
$TLS11Members = Get-ADGroupMember -Identity $TLS11

HV1
HV2
HV3
HV4
SERVER2
SERVER3
$AddList = Get-Clipboard
$AddList
foreach ($Entry in $AddList) {
    Add-ADGroupMember -Identity $TLS10 -Members (Get-ADComputer -Identity $Entry)
}
Get-ADGroupMember -Identity $TLS10 | sort Name | select Name

# Remove computer accounts from a group
HV1
HV2
HV3
HV4
$RemoveList = Get-Clipboard
$RemoveList
foreach ($Entry in $RemoveList) {
    Remove-ADGroupMember -Identity $TLS10 -Members (Get-ADComputer -Identity $Entry) -Confirm:$false
}
Get-ADGroupMember -Identity $TLS10 | sort Name | select Name
