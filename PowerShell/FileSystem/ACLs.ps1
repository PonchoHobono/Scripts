# Disable folder permission inheritance. Copy permissions.
    # https://docs.microsoft.com/en-us/dotnet/api/system.security.accesscontrol.objectsecurity.setaccessruleprotection?view=dotnet-plat-ext-3.1
    # SetAccessRuleProtection($true,$true)
    # First parameter is whether inheritance is disabled ($true) or enabled ($false).
    # Second parameter is to copy ($true) or remove ($false) inherited permissions.
$Folder = "C:\Test"
$ACL = Get-Acl -Path $Folder
$ACL.Access
$ACL.SetAccessRuleProtection($true,$true)
Set-Acl -Path $Folder -AclObject $ACL


# Disable folder permission inheritance. Remove inherited permissions. Careful with this one.
$Folder = "C:\Test"
$ACL = Get-Acl -Path $Folder
$ACL.Access
$ACL.SetAccessRuleProtection($true,$false)
Set-Acl -Path $Folder -AclObject $ACL


# Enable folder permission inheritance.
$Folder = "C:\Test"
$ACL = Get-Acl -Path $Folder
$ACL.Access
$ACL.SetAccessRuleProtection($false,$true)
Set-Acl -Path $Folder -AclObject $ACL


# Assign a user permissions to a folder
# To see a list of all types of permissions run:
    [system.enum]::getnames([System.Security.AccessControl.FileSystemRights])
# Arguements:
    # IdentityReference, FileSystemRights, InheritanceFlags, PropagationFlags, AccessControlType
# Options for InheritanceFlags & PropagationFlags (e.g. "Applies To"):
    # This folder only                     'None', 'None'
    # This folder, subfolders and files    'ContainerInherit, ObjectInherit', 'None'
    # This folder and subfolders           'ContainerInherit', 'None'
    # This folder and files                'ObjectInherit', 'None'
    # Subfolder and files only             'ContainerInherit, ObjectInherit', 'InheritOnly'
    # Subfolder only                       'ContainerInherit', 'InheritOnly'
    # Files only                           'ObjectInherit', 'InheritOnly'
$Folder = "C:\Test"
$ACL = Get-Acl -Path $Folder
$IdentityReference = "LAPTOPLAB\AdminPatrick"
$FileSystemRights = "FullControl"
$InheritanceFlags = "ContainerInherit, ObjectInherit"
$PropagationFlags = "None"
$AccessControlType = "Allow"
$Permission = $IdentityReference,$FileSystemRights,$InheritanceFlags,$PropagationFlags,$AccessControlType
$AccessRule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $Permission
$ACL.SetAccessRule($AccessRule)
Set-Acl -Path $Folder -AclObject $ACL


# Remove a user's permission to a folder
$Folder = "C:\Test"
$ACL = Get-Acl -Path $Folder
$IdentityReference = "LAPTOPLAB\AdminPatrick"
$FileSystemRights = "FullControl"
$InheritanceFlags = "ContainerInherit, ObjectInherit"
$PropagationFlags = "None"
$AccessControlType = "Allow"
$Permission = $IdentityReference,$FileSystemRights,$InheritanceFlags,$PropagationFlags,$AccessControlType
$AccessRule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $Permission
$ACL.RemoveAccessRule($AccessRule) | Out-Null
Set-Acl -Path $Folder -AclObject $ACL


# Remove all non-inherited permissions
$Folder = "C:\Test"
$ACL = Get-Acl -Path $Folder
$NonInherited = $ACL.Access | where {$_.IsInherited -eq $false}
foreach ($Entry in $NonInherited) {
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($Entry.IdentityReference,$Entry.FileSystemRights,$Entry.InheritanceFlags,$Entry.PropagationFlags,$Entry.AccessControlType)
    $ACL.RemoveAccessRule($AccessRule)
    Set-Acl -Path $Folder -AclObject $ACL
}


# Change folder owner
$Folder = "C:\Test"
$ACL = Get-Acl -Path $Folder
$Owner = New-Object System.Security.Principal.Ntaccount("SYSTEM")
$ACL.SetOwner($Owner)
Set-Acl -Path $Folder -AclObject $ACL


# Scenario 1 - You want to remove all explicit & inherited permissions on a folder then set specific permissions. Do them in this order.
# Clear current explicit permissions
    $Folder = "C:\Test"
    $ACL = Get-Acl -Path $Folder
    $NonInherited = $ACL.Access | where {$_.IsInherited -eq $false}
    foreach ($Entry in $NonInherited) {
        $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($Entry.IdentityReference,$Entry.FileSystemRights,$Entry.InheritanceFlags,$Entry.PropagationFlags,$Entry.AccessControlType)
        $ACL.RemoveAccessRule($AccessRule) | Out-Null
        Set-Acl -Path $Folder -AclObject $ACL
    }
# Set desired permissions. Repeat this section as needed.
    $ACL = Get-Acl -Path $Folder
    $IdentityReference = "LAPTOPLAB\AdminPatrick"
    $FileSystemRights = "FullControl"
    $InheritanceFlags = "ContainerInherit, ObjectInherit"
    $PropagationFlags = "None"
    $AccessControlType = "Allow"
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($IdentityReference,$FileSystemRights,$InheritanceFlags,$PropagationFlags,$AccessControlType)
    $ACL.SetAccessRule($AccessRule)
    Set-Acl -Path $Folder -AclObject $ACL
# Remove Inheritance, do not copy permissions.
    $Folder = "C:\Test"
    $ACL = Get-Acl -Path $Folder
    $ACL.SetAccessRuleProtection($true,$false)
    Set-Acl -Path $Folder -AclObject $ACL


# Scenario 2 - Same as before but using a file that contains the permissions.
#              You want to remove all explicit & inherited permissions on a folder then set specific permissions. Do them in this order.
# CSV Contents (minus the #)
    #IdentityReference,FileSystemRights,InheritanceFlags,PropagationFlags,AccessControlType
    #BUILTIN\SYSTEM,FullControl,"ContainerInherit, ObjectInherit",None,Allow
    #BUILTINAdministrators,FullControl,"ContainerInherit, ObjectInherit",None,Allow
    #BUILTIN\Users,Read,"ContainerInherit, ObjectInherit",None,Allow
# Clear current static permissions
    $Folder = "C:\Test\Target"
    $ACL = Get-Acl -Path $Folder
    $ACL.Access | ft
    $NonInherited = $ACL.Access | where {$_.IsInherited -eq $false}
    $NonInherited | ft
    foreach ($Entry in $NonInherited) {
        $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($Entry.IdentityReference,$Entry.FileSystemRights,$Entry.InheritanceFlags,$Entry.PropagationFlags,$Entry.AccessControlType)
        $ACL.RemoveAccessRule($AccessRule) | Out-Null
        Set-Acl -Path $Folder -AclObject $ACL
    }
# Set desired permissions.
    $NewACLs = Import-Csv -Path C:\Temp\ACL.txt
    # or if CSV doesn't have headers.
    $NewACLs = Import-Csv -Path C:\Temp\ACL_No_Header.txt -Header IdentityReference,FileSystemRights,InheritanceFlags,PropagationFlags,AccessControlType
    $Folder = "C:\Test\Target"
    $ACL = Get-Acl -Path $Folder
    $ACL.Access | ft
    foreach ($NewACL in $NewACLs) {
        $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($NewACL.IdentityReference,$NewACL.FileSystemRights,$NewACL.InheritanceFlags,$NewACL.PropagationFlags,$NewACL.AccessControlType)
        $ACL.SetAccessRule($AccessRule)
        Set-Acl -Path $Folder -AclObject $ACL
    }
# Remove Inheritance, do not copy permissions.
    $Folder = "C:\Test\Target"
    $ACL = Get-Acl -Path $Folder
    $ACL.SetAccessRuleProtection($true,$false)
    Set-Acl -Path $Folder -AclObject $ACL


# Copy permissions from one folder to another
Get-Acl -Path C:\Test\Target | Set-Acl -Path C:\Test\Target2
