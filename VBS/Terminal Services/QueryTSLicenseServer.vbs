' No clue where I got this from. Probably some CD that came with a book.

'**********************************************************
' 
' WMI VBScript that queries the License servers configured 
' for registry bypass.
'
' on the Terminal server
'
'**********************************************************
for each Terminal in GetObject("winmgmts:{impersonationLevel=impersonate}").InstancesOf	("win32_TerminalServiceSetting")
	WScript.Echo "The License Servers are = " & Terminal.DirectConnectLicenseServers
next
'**************** end of script***************************
