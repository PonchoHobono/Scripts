On Error Resume Next

strComputer = "."
Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")

Set colItems = objWMIService.ExecQuery _
    ("Select * from Win32_NetworkAdapterConfiguration Where MACAddress = '00:0E:0C:66:77:80'")

If colItems.Count = 0 Then
    Wscript.Echo "There are no adapters with that MAC address."
    Wscript.Quit
End If

For Each objItem in colItems
    For Each strIPAddress in objItem.IPAddress
        Wscript.Echo "IP Address: " & strIPAddress
    Next
Next