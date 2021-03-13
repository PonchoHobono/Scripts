msgbox "1"

EnableDisableNIC

msgbox "2"

EnableDisableNIC

Function EnableDisableNIC
	'http://www.mcpmag.com/columns/article.asp?EditorialsID=619
	
	
	set objShell=CreateObject("shell.application")
	'Toggle NIC on or off
	Dim objCP, objEnable, objDisable, colNetwork
	Dim clsConn, clsLANConn, clsVerb
	Dim strNetConn, strConn, strEnable, strDisable
	Dim bEnabled, bDisabled
	
	strNetConn = "Network Connections"
	strConn = "Local Area Connection"
	
	strEnable = "En&able"
	strDisable = "Disa&ble"
	
	Set objCP = objShell.Namespace(3) 'Control Panel
	
	Set colNetwork = Nothing
	For Each clsConn in objCP.Items
	If clsConn.Name = strNetConn Then
	Set colNetwork = clsConn.getfolder
	Exit For
	End If
	Next
	
	If colNetwork is Nothing Then
	WScript.Echo "Network folder not found"
	WScript.Quit
	End If
	
	Set clsLANConn = Nothing
	For Each clsConn in colNetwork.Items
	'In case the LAN is named "connection 2", etc.
	
	If Instr(LCase(clsConn.name),LCase(strConn)) Then
	Set clsLANConn = clsConn
	Exit For
	End If
	Next
	
	If clsLANConn is Nothing Then
	WScript.Echo "Network Connection not found"
	WScript.Quit
	End If
	
	bEnabled = True
	Set objEnable = Nothing
	Set objDisable = Nothing
	For Each clsVerb in clsLANConn.verbs
	If clsVerb.name = strEnable Then 
	Set objEnable = clsVerb 
	bEnabled = False
	End If
	If clsVerb.name = strDisable Then 
	Set objDisable = clsVerb 
	End If
	Next
	
	If bEnabled Then
	objDisable.DoIt
	Else
	objEnable.DoIt
	End If
	
	'Give the connection time to stop/start
	WScript.Sleep 1000
End Function