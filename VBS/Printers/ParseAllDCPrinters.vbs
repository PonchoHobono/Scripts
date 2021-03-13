ON ERROR RESUME NEXT
Dim WshNetwork, WshPrinters, objFSO, tf

Const ForAppending = 8
Set objFSO = CreateObject("Scripting.FileSystemObject")
Set WshNetwork = CreateObject("WScript.Network")
Set WshPrinters = WshNetwork.EnumPrinterConnections
Set tf = objFSO.OpenTextFile("\\NAS1\Logs$\Printers.txt", ForAppending, True)

For i = 0 To WshPrinters.Count - 1 Step 2
    'WRITE ALL DC PRINTERS TO LOG FILE
	If LCase(Left(WshPrinters.Item(i +1),4)) = "\\dc" Then
		tf.WriteLine(WshNetwork.UserName & "," & WshNetwork.ComputerName & "," & WshPrinters.Item(i +1) & "," & Now())
	End If
Next

'CLEAN UP
set WshNetwork = Nothing
Set WshPrinters = Nothing  

'QUIT THE SCRIPT
wscript.quit
