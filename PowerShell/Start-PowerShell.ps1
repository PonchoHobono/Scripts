function Start-PowerShell {
    <#
    .SYNOPSIS
        Starts an instance of PowerShell or PowerShell ISE.

    .DESCRIPTION
        Starts an instance of PowerShell or PowerShell ISE.

    .PARAMETER Session
        The Session parameter is used to select whether PowerShell or PowerShell ISE should be run..

    .PARAMETER Credential
        The Credential parameter is the credential for the alternate account.

    .INPUTS
        Does not accept objects from the pipeline.

    .OUTPUTS
        None.

    .EXAMPLE
        Start-PowerShell -Session ISE -Credential DOMAIN\Admin1 -Elevate

    .EXAMPLE
        $Cred = Get-Credential
        Start-PowerShell -Session PowerShell -Credential $Cred -Elevate

    .NOTES
        https://medium.com/river-yang/powershell-run-as-another-user-elevate-the-process-58b90fc4d11d
        https://gist.github.com/atao/a103e443ffb37d5d0f0e7097e4342a28
        https://duffney.io/addcredentialstopowershellfunctions

    #>

    [CmdletBinding(DefaultParameterSetName="Default")]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeLine=$false,ParameterSetName="Default")]
        [ValidateSet("PowerShell","ISE")]
        [string]$Session,
        [Parameter(Mandatory=$true,ValueFromPipeLine=$false,ParameterSetName="Default")]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,
        [Parameter(Mandatory=$false,ValueFromPipeLine=$false,ParameterSetName="Default")]
        [switch]$Elevate
    )

    Begin {
    }
    Process {
        try {
            if ($Session -eq "ISE") {
                $EXE = "PowerShell_ISE.exe"
            } else {
                $EXE = "PowerShell.exe"
            }
            if ($Elevate) {
                $RunAs = "-Verb RunAs"
            } else {
                $RunAs = ""
            }
            Start-Process -FilePath Powershell.exe -Credential $Credential -ArgumentList "Start-Process -FilePath $EXE $RunAs"
        }
        catch {
        }
    }
    End {
    }
}
