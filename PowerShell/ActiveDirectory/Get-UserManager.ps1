Function Get-UserManager {
    
    [CmdletBinding(
        DefaultParameterSetName='Identity'
    )]
    Param (
	    [Parameter(
            ParameterSetName='Identity',Mandatory=$true,ValueFromPipeline=$true,Position=0)]
	    [String[]]$Identity,
        [Parameter(
            ParameterSetName='File',Mandatory=$true,ValueFromPipeline=$false,Position=0)]
	    [String]$Path,
        [Parameter(
            ParameterSetName='Identity',Mandatory=$false,ValueFromPipeline=$false,Position=1)]
        [Parameter(
            ParameterSetName='File',Mandatory=$false,ValueFromPipeline=$false,Position=1)]
	    [String]$Output
    )

    If ($Path) {
        $Identity = Get-Content -Path $Path
    }

    $Return = @()
    ForEach ($User in $Identity) {
        $Object = @()
        Try {
            $UserInfo = Get-ADUser -Identity $User -Properties EmailAddress,Manager -ErrorAction Stop
        }
        Catch {
            continue
        }
        If ($UserInfo) {
            If ($UserInfo.Manager) {
                $ManagerInfo = Get-ADUser -Identity $UserInfo.Manager -Properties EmailAddress
            } Else {
               # No Manager attribute set.
               $ManagerInfo = ""
            }
            $Object = [pscustomobject]@{
                UserID = $UserInfo.SamAccountName
                #Name = $UserInfo.Name
                Name = $UserInfo.GivenName + " " + $UserInfo.Surname
                Email = $UserInfo.EmailAddress
                ManagerID = $ManagerInfo.SamAccountName
                ManagerName = $ManagerInfo.GivenName + " " + $ManagerInfo.Surname
                ManagerEmail = $ManagerInfo.EmailAddress
            }
            $Return += $Object
        }
    }

    If ($Output) {
        If (Test-Path -Path $Output) {
            #$Return | Export-Csv -Path $Output -NoTypeInformation
            [string]$Date = Get-Date -Format yyyyMMddhhmmss
            #$File = "C:\Temp\$Date`_UsersManagers.csv"
            Write-Host $Output\$Date`_UsersManagers.csv
        } Else {
            Write-Host "$Output does not exists." -ForegroundColor Red
            Return $Return
        }
    } Else {
        Return $Return
    }
}
