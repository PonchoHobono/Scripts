' Ref http://www.neowin.net/forum/topic/1198741-vbscript-check-to-see-if-microsoft-hoxfix-kb-is-not-installed,
'     http://stackoverflow.com/questions/187040/how-do-i-return-an-exit-code-from-a-vbscript-console-application

On Error Resume Next
 
strComputer = "."
Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")
Set colItems = objWMIService.ExecQuery("Select * from Win32_QuickFixEngineering",,48)
Set objFSO=CreateObject("Scripting.FileSystemObject")
Set wshNetwork = WScript.CreateObject( "WScript.Network" )
strComputerName = wshNetwork.ComputerName

kbFound = 0 

For Each objItem in colItems
	If objItem.HotfixID = "KB2590550" then
		'outFile="\\F30-CHI\D$\VBTest\" & strComputerName
		'Set objFile = objFSO.CreateTextFile(outFile,True)
		'objFile.Close
		kbFound = 1
		Exit For
	End If
Next

If kbFound = 0 Then
	'Patch was not found
	WScript.Quit(kbFound)
Else
	'Patch was found
	WScript.Quit(kbFound)
End If