ON ERROR RESUME NEXT
Dim WSNetwork, WSPrinters

Set WSNetwork = CreateObject("WScript.Network")
Set WSPrinters = WSNetwork.EnumPrinterConnections
'Wscript.Echo WSPrinters.Count
For i = 0 To WSPrinters.Count - 1 Step 2
    'REMOVE ALL PRINTERs THAT ARE ON A PRINT SERVER THAT STARTS WITH DC
	If LCase(Left(WSPrinters.Item(i +1),4)) = "\\dc" Then
		'Wscript.Echo "Printer " & WSPrinters.Item(i +1) & " will be removed."
		WSNetwork.RemovePrinterConnection WSPrinters.Item(i +1),True,True
	End If
Next

'Clean Up Memory We Used
set WSNetwork = Nothing
Set WSPrinters = Nothing  

'Quit the Script
wscript.quit