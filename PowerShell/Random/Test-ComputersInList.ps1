function Test-ComputersInList {
<#
.SYNOPSIS
    
.DESCRIPTION
    
.PARAMETER ComputerName

.PARAMETER Chatty
    
.EXAMPLE
    
.EXAMPLE
     
.EXAMPLE
    
.NOTES
    
.LINK

#>
    
    [CmdletBinding(
        DefaultParameterSetName="Default"
    )]
    Param (
        [Parameter(ParameterSetName="Default",Mandatory=$false,ValueFromPipeline=$false,Position=0)]
            [String[]]$ComputerName = $env:COMPUTERNAME,
        [Parameter(ParameterSetName="Default",Mandatory=$false,ValueFromPipeLine=$false)]
            [switch]$Chatty
    )
    
    begin {
        $ScriptBlock =  {
            Write-Host $env:COMPUTERNAME
        } # End of Scriptblock
    }
    process {
        try {
            if ($ComputerName.Contains($env:COMPUTERNAME)) {
                Write-Host "Running local then remote"
                & $ScriptBlock
                # Remove local computer from array
                $UpdatedComputerName = $ComputerName | Where-Object { $PSItem –ne $env:COMPUTERNAME }
                Invoke-Command -ComputerName $UpdatedComputerName -ScriptBlock $ScriptBlock -ArgumentList $PSBoundParameters
            } else {
                Write-Host "Running remote only"
                Invoke-Command -ComputerName $ComputerName -ScriptBlock $ScriptBlock -ArgumentList $PSBoundParameters
            }
        }
        catch {
            Write-Error -Message "Error: $($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)"
        }
    }
    end {
        if ($Chatty) {
            $Message = "All Done"
            Write-Host "[$env:COMPUTERNAME] $Message" -ForegroundColor Green
        }
    }
    
} # End of Test-ComputersInList function

SERVER01
SERVER02
SERVER03

$Servers = Get-Clipboard
Test-ComputersInList -ComputerName $Servers
