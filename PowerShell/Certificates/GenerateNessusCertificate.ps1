# This is still a work in progress.

# Borrowed lots of code from: https://github.com/J0F3/PowerShell/blob/master/Request-Certificate.ps1

# Variables to update as needed
[string]$CN = "nessus.laptoplab.net"
[String]$TemplateName = "LabSSLWebCertificateCustom"

# Other Variables
[string[]]$SAN = "DNS=$CN"
[string]$Date = Get-Date -Format yyyyMMddhhmmss
[string]$FriendlyName = """Nessus $Date"""
[int]$keyLength = 2048
[string]$NessusCAPath = "C:\ProgramData\Tenable\Nessus\nessus\CA"
$Password = ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force
# CA
$rootDSE = [System.DirectoryServices.DirectoryEntry]'LDAP://RootDSE'
$searchBase = [System.DirectoryServices.DirectoryEntry]"LDAP://$($rootDSE.configurationNamingContext)"
$CAs = [System.DirectoryServices.DirectorySearcher]::new($searchBase,'objectClass=pKIEnrollmentService').FindAll()
if($CAs.Count -eq 1){
    $CAName = "$($CAs[0].Properties.dnshostname)\$($CAs[0].Properties.cn)"
}
else {
    $CAName = ""
}
if (!$CAName -eq "") {
    #$CAName = " -config `"$CAName`""
    #$CAName = "`"$CAName`""
    $CAName = "$CAName"
}

# Stop Tenable service
Stop-Service -Name 'Tenable Nessus'

# INF Template
$file = @"
[NewRequest]
FriendlyName = $FriendlyName
Subject = "CN=$CN,c=$Country,s=$State,l=$City,o=$Organisation,ou=$Department"
MachineKeySet = TRUE
KeyLength = $KeyLength
KeySpec=1
Exportable = TRUE
RequestType = PKCS10
ProviderName = "Microsoft Enhanced Cryptographic Provider v1.0"
[RequestAttributes]
CertificateTemplate = "$TemplateName"
"@

# SAN Certificate
if (($SAN).count -eq 1) {
    $SAN = @($SAN -split ',')
}
$file += 
@'

[Extensions]
; If your client operating system is Windows Server 2008, Windows Server 2008 R2, Windows Vista, or Windows 7
; SANs can be included in the Extensions section by using the following text format. Note 2.5.29.17 is the OID for a SAN extension.

2.5.29.17 = "{text}"

'@
foreach ($an in $SAN) {
    $file += "_continue_ = `"$($an)&`"`n"
}

# Create temp files
$inf = Join-Path -Path $env:TEMP -ChildPath "$CN.inf"
$req = Join-Path -Path $env:TEMP -ChildPath "$CN.req"
$cer = Join-Path -Path $env:TEMP -ChildPath "$CN.cer"

# Create new request inf file
Set-Content -Path $inf -Value $file

# Create certificate request (CSR)
Invoke-Expression -Command "certreq -new `"$inf`" `"$req`""

# Private Key
#$Request = certutil -dump $req
#$X = $Request | Select-String "Subject Key Identifier" -Context(0,1)
#$X.Context.PostContext
#[string]$SKI = "f0 6c eb 4a a3 d5 bb de a5 da 43 0f 68 e0 f6 3d a5 cf 7b c3".Replace(' ','')
#$CertificateRequest = Get-ChildItem -Path Cert:\LocalMachine\REQUEST | Where-Object {$_.Subject -like "CN=nessus.laptoplab.net*"}
 #Get-ChildItem -Path Cert:\LocalMachine\REQUEST | Where-Object {$_.Subject -like "CN=$CN*"} | sort NotBefore -Descending | select NotBefore,Thumbprint,Subject
$CertificateRequest = Get-ChildItem -Path Cert:\LocalMachine\REQUEST | Where-Object {$_.Subject -like "CN=$CN*"} | sort NotBefore | Select-Object -Last 1
Export-PfxCertificate -Cert $CertificateRequest -Password $Password -FilePath "$env:TEMP\$CN.pfx"

# Convert PFX to PEM. Ignore error on RSA command. It still creates the KEY file.
Set OPENSSL_CONF=C:\Program Files\OpenSSL-Win64\bin\openssl.cfg
Set-Location -Path 'C:\Program Files\OpenSSL-Win64\bin'
#.\openssl.exe pkcs12 -in C:\Users\Administrator.LAPTOPLAB\AppData\Local\Temp\nessus.laptoplab.net.pfx -nocerts -out C:\Users\Administrator.LAPTOPLAB\AppData\Local\Temp\nessus.laptoplab.net.pem -passin pass:P@ssw0rd -passout pass:P@ssw0rd
.\openssl.exe pkcs12 -in $env:TEMP\$CN.pfx -nocerts -out $env:TEMP\$CN.pem -passin pass:P@ssw0rd -passout pass:P@ssw0rd
#.\openssl.exe rsa -in C:\Users\Administrator.LAPTOPLAB\AppData\Local\Temp\nessus.laptoplab.net.pem -out C:\Users\Administrator.LAPTOPLAB\AppData\Local\Temp\nessus.laptoplab.net.key -passin pass:P@ssw0rd -passout pass:P@ssw0rd
.\openssl.exe rsa -in $env:TEMP\$CN.pem -out $env:TEMP\$CN.key -passin pass:P@ssw0rd -passout pass:P@ssw0rd
Set-Location -Path C:\Temp

# Submit CSR
#Write-Host "certreq -submit$CAName `"$req`" `"$cer`""
#Write-Host "certreq -submit -config $CAName `"$req`" `"$cer`""
#Write-Host "certreq -submit -config `"$CAName`" `"$req`" `"$cer`""
#Invoke-Expression -Command "certreq -submit$CAName `"$req`" `"$cer`""
Invoke-Expression -Command "certreq -submit -config `"$CAName`" `"$req`" `"$cer`""

# Retrieve certificate
Invoke-Expression -Command "certreq -accept `"$cer`""

# Export certificate
$IssuedCertificate = Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object {$_.Subject -like "CN=$CN*"} | sort NotBefore | Select-Object -Last 1
Export-Certificate -Cert $IssuedCertificate -FilePath "$env:TEMP\$CN`_Issued.cer"
# Convert to Base64
certutil -encode "$env:TEMP\$CN`_Issued.cer" "$env:TEMP\$CN`_Issued_Base64.cer"

# Get CA Certificate
# https://www.powershellgallery.com/packages/CertificatePS/1.2/Content/Copy-CertificateToRemote.ps1
[int]$iteration = 1
$Chain = New-Object System.Security.Cryptography.X509Certificates.X509Chain
$Chain.Build($IssuedCertificate)
$Chain.ChainElements | Select-Object -ExpandProperty Certificate -Skip 1 | ForEach-Object {
    $iteration++
    $CertificatePath = Join-Path $env:TEMP "$("{0:00}" -f $iteration).$($_.Thumbprint).cer"
    $_ | Export-Certificate -FilePath $CertificatePath | Out-Null
}

# Update Nessus certificate files
$Date = Get-Date -Format yyyyMMddhhmmss
Rename-Item -Path $NessusCAPath\cacert.pem -NewName $NessusCAPath\cacert`_$Date.pem
#Copy-Item -Path $env:TEMP\03.97A2D8212FCB85B9A2EF3D75B50BC1EF078D0298.cer -Destination $NessusCAPath\cacert.pem
Rename-Item -Path $NessusCAPath\servercert.pem -NewName $NessusCAPath\servercert`_$Date.pem
Copy-Item -Path $env:TEMP\$CN`_Issued_Base64.cer -Destination $NessusCAPath\servercert.pem -Force
Rename-Item -Path $NessusCAPath\serverkey.pem -NewName $NessusCAPath\serverkey`_$Date.pem
Copy-Item -Path $env:TEMP\$CN`.key -Destination $NessusCAPath\serverkey.pem -Force

# Start Tenable service
Start-Service -Name 'Tenable Nessus'

# Cleanup
$Cleanup = Get-ChildItem -Path $env:TEMP | Where-Object {$_.Name -like "$CN*"}
Remove-Item -Path $Cleanup.FullName
