' THIS SCRIPT ENABLES OR DISABLES THE FIREWALL CLIENT. IT CAN BE USED IN A LOGON OR LOGOFF SCRIPT.
' 1 = Disabled
' 0 = Enabled

Dim objFSO, objWS
Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objWS = CreateObject("Wscript.Shell")
If (objFSO.FileExists("C:\Program Files\Microsoft Firewall Client\ISATRAY.EXE")) Then       
   objWS.RegWrite "HKLM\SOFTWARE\Microsoft\Firewall Client\Disable", 1, "REG_DWORD" 
End if
