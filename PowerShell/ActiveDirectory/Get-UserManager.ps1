Function Get-UserManager {
    
    [CmdletBinding(
        DefaultParameterSetName='Identity'
    )]
    Param (
	    [Parameter(
            ParameterSetName='Identity',
            Mandatory=$true,ValueFromPipeline=$true,Position=0
        )]
	    [String[]]$Identity,
        [Parameter(
            ParameterSetName='File',
            Mandatory=$true,ValueFromPipeline=$false,Position=0
        )]
	    [String]$Path
    )

    If ($Path) {
        $Identity = Get-Content -Path $Path
    }

    $Return = @()
    ForEach ($User in $Identity) {
        $Object = @()
        $UserInfo = Get-ADUser -Identity $User -Properties EmailAddress,Manager #-ErrorAction SilentlyContinue
        If ($UserInfo.Manager) {
            $Manager = ($UserInfo.Manager).Split('=,')[1]
            $ManagerInfo = Get-ADUser -Identity $Manager -Properties EmailAddress
        } Else {
            # No Manager attribute set.
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
    Return $Return
}
