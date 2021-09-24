function Get-SccmClientComplianceBasline {
<#
.SYNOPSIS
    Gets the SCCM compliance baselines on a computer.
.DESCRIPTION
    Gets the SCCM compliance baselines on a computer.
.PARAMETER ComputerName
    The Computer to connect to.
.INPUTS
    Accepts an array of computer names.
.OUTPUTS
    
.EXAMPLE
    Get-SccmClientComplianceBasline -ComputerName SERVER1
.NOTES
    Create by: Patrick Hoban
#>

    [CmdletBinding(
        DefaultParameterSetName="Default"
    )]
    Param (
        [Parameter(ParameterSetName="Default",Mandatory=$false,ValueFromPipeline=$false,Position=0)]
            [String[]]$ComputerName = $env:COMPUTERNAME
    )

    begin {
        $ScriptBlock = {
            $Return = @()
            $AllBaselines = Get-WmiObject -Namespace root\ccm\dcm -Class SMS_DesiredConfiguration
            foreach ($Baseline in $AllBaselines) {
                if (($Baseline.LastEvalTime.length -ne '0') -and ($Baseline.LastEvalTime -ne '00000000000000.000000+000') -and ($Baseline.LastEvalTime -ne $null)) {
                    $LastEvalTime = $Baseline.ConvertToDateTime($Baseline.LastEvalTime)
                } else {
                    $LastEvalTime = 'N/A'
                }
                $Object = [pscustomobject]@{
                    Name = $Baseline.DisplayName
                    Revision = $Baseline.Version
                    'Last Evaluation' = $LastEvalTime
                    'Compliance State' = $Baseline.LastComplianceStatus
                    'Evaluation State' = $Baseline.Status
                }
                $Return += $Object
            }
            $Return
        }
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
