strComputer = "."
Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")

Set colItems = objWMIService.ExecQuery _
    ("Select * from Win32_NetworkAdapter")

For Each objItem in colItems
    Wscript.Echo objItem.Name, objItem.MACAddress
Next

