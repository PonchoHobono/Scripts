# Work in progress

$Content = Import-Excel -Path 'C:\Temp\New Text Document.xlsx'
#$Content[0].'Plugin Output'
#$Content[0].'Plugin Output' | Select-String "Actual Value:"
#$Content[0].'Plugin Output'.ToCharArray()
#$Results = $Content[0].'Plugin Output'.Split([Environment]::NewLine)
$Results = $Content[0].'Plugin Output' -split "[\r\n]+"
foreach ($line in $Results) {
    Write-Host $line
    Write-Host "Test"
}
$Results | Select-String "Actual Value:"
$Results | Select-String "Policy Value:"
