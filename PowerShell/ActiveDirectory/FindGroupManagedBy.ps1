# This quick code block will search through Active Directory at the SearchBase you specify & look for
# any groups that have the "ManagedBy" attribute set for the User/Group specified in the SearchFor vairable.

# Variables
$SearchBase = "OU=Groups,OU=Lab,DC=laptoplab,DC=net"
$SeachFor = "*POLICY_Test*"

# Code
$Groups = Get-ADGroup -SearchBase $SearchBase  -Filter * -Properties managedBy
ForEach ($Group in $Groups) {
    If ($Group.managedBy -like $SeachFor) {
        Write-Host $Group.Name -ForegroundColor Green
    }
}
