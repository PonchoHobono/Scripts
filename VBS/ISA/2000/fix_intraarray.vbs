'-----------------------------------------------------------
'	Examines and corrects IntraArrayAddress data
'
'	Copyright (c) 2002: Jim Harrison (jim@isatools.org)
'	Date: 09/02/2002
'
'	Version: 1.3
'
'	History:
'		1.0; 09/02/2002 - First working version
'		1.2; 01/24/2003 - Understands Standalone (reg-based) ISA now
'		1.3; 06/02/2003 - Understands that Cache mode has no LAT <duh>
'-----------------------------------------------------------

Option Explicit

Main

Sub Main

	Dim Data 
	Dim Good: Good = False

	Set Data = New IntData

	'Now let's see If it even belongs to the ISA
	If ChkIsISA( Data.IAA ) Then
		'Is it in the LAT?
		If ChkIsLAT( Data, Data.IAA ) Then 
			Good = True
			Data.Msg = Data.Nada
		Else
			Data.Msg = Data.IAA & Data.NotLAT
			BadIP (Data)
		End If
	Else
		Data.Msg = Data.IAA & Data.Unowned
		BadIP (Data )
	End If

	If Not Good Then 
		'Make sure the ISA has the latest data
		Data.Msg = Data.Changed
		Data.ISA.Refresh
	End If

	Data.WshShell.Popup Data.Msg, 10, Data.MsgTitle, 64

	Set Data = Nothing

End Sub

'-----------------------------------------------------------
' Ask the user to verIfy that they really want to quit
'-----------------------------------------------------------

Sub AskQuit(Data)

	Dim Rtn

	Rtn = MsgBox (Data.Quit, vbYesNo, Data.MsgTitle)
	If Rtn = vbYes Then WScript.Quit

	Err.Clear

End Sub

'-----------------------------------------------------------
' ISA doesn't own the IP specIfied in the IAA
'-----------------------------------------------------------

Sub BadIP( Data )

	Dim RegLoc
	
	Const fpcTypeArray = 2
	Const RegRoot = "HKLM\"
	Const RegPath = "Software\Microsoft\Fpc\Arrays"
	Const RegVal = "msFPCIntraArrayAddress"

	Data.IntIP = InputBox( Data.Msg, Data.MsgTitle, Data.IntIP )
	
	If Data.IntIP = "" Then 
		AskQuit( Data )
		BadIP ( Data )
	End If		

	' check to see If it's an ISA-owned IP
	If ChkIsISA( Data.IntIP ) Then
		' now see If it's in the LAT
		If Not ChkIsLAT( Data, Data.IntIP )  Then 
			Data.Msg = Data.IntIP & Data.NotLat
			BadIP ( Data )
		End If
		' now see If we're in an Enterprise array
		If Data.ISA.Type = fpcTypeArray Then 
			Data.Server.IntraArrayAddress = Data.IntIP
			Data.Server.Save
		Else
		' must be in standalone (registry) mode
			RegLoc = RegRoot & FindServer( RegPath )
			Data.WshShell.RegWrite RegLoc & RegVal, Data.IntIP, "REG_SZ"
		End If
	Else
		Data.Msg = Data.IntIP & Data.Unowned
		BadIP ( Data )
	End If

End Sub

'-----------------------------------------------------------
' See If "IP" is in the ISA Local Address Table
'-----------------------------------------------------------

Function ChkIsLAT(Data, IP)

	Dim LAT

	Const CacheMode = 4
	
	If Data.ISAArray.Components = CacheMode Then
		'everything is "LAT" to cache mode
		ChkIsLAT = True
	Else
		Set LAT = Data.ISAArray.NetworkConfiguration.LAT
		ChkIsLat = LAT.IsIPInternal(IP)
	End If

	Err.Clear

End Function

'-----------------------------------------------------------
' See If "IP" belongs to the ISA server
'-----------------------------------------------------------

Function ChkIsISA(IP)

	Dim NICS, NIC, i, Msg

	ChkIsISA = False
	Const strQuery = "Select * From Win32_NetworkAdapterConfiguration where IPEnabled = True"

	Set NICS = GetObject("winmgmts:").ExecQuery(strQuery)
	If Err Then
		Msg = WMIErr
		WScript.Echo "Error creating NICS" & Msg
		WScript.Quit
	End If

	For Each NIC in NICS
		If NIC is Nothing Then
			WScript.echo Err.description
			WScript.Quit
		End If
		If isarray(NIC.IPAddress) Then
			For i = 0 to UBound(NIC.IPAddress)
				If IP = NIC.IPAddress(i) Then
					ChkIsISA = True
					Exit For
				End If
			Next
		Else
			If IP = NIC.IPAddress Then ChkIsISA = True
		End If
	Next

	Err.Clear

End Function

'-----------------------------------------------------------
' locate the "IntraArrayAddress" registry value parent key
'
' This is a little tricky since while we know it's stored in 
' HKLM\Software\Microsoft\Fpc\Arrays\{GUID}\Servers\{GUID}, but
' we don't know the {GUID} values at the outset.  
' Luckily, there's only one of each per ISA Server
'-----------------------------------------------------------

Function FindServer( Root )

	Const HKLM = &H80000002

	Dim lRC
	Dim sPath
	Dim sKeys()
	Dim objRegistry
	Dim Counter

	Set objRegistry = GetObject("winmgmts:root\default:StdRegProv")

	lRC = objRegistry.EnumKey(HKLM, Root, sKeys)

	If (lRC = 0) And (Err.Number = 0) Then
		If Right( Root, 6 ) = "Arrays" Then
				'get the one and only Array {GUID} value and append the "Servers" key
				Root = Root & "\" & sKeys( 0 ) & "\Servers\"
				FindServer = FindServer( Root )
		Else
				'get the one and only Server {GUID} value and append "\"
				FindServer = Root & sKeys( 0 ) & "\"
		End If
	Else
		WScript.Echo "Error " & Hex(Err.Number) & " while enumerating the keys in " & Root
		WScript.Quit
	End If

End Function

'-----------------------------------------------------------
' Get the WMI Error data
'-----------------------------------------------------------

Function WMIErr

	On Error Resume Next
	Dim t_object, strDescr, strPInfo, strCode, strMsg

	set t_object = CreateObject("WbemScripting.SWbemLastError")
	If Err Then
		WMIErr = "** Error " & Err.Description
		Err.Clear
		Exit Function
	End If

	strMsg = "WMI Error: " & _
	" -Operation: " & t_object.Operation & _
	" -Provider: " & t_object.ProviderName


	strDescr = t_object.Description
	If strDescr <> "" Then strMsg = strMsg & " -Description: " & strDescr

	strPInfo = t_object.ParameterInfo
 	If strPInfo <> "" Then strMsg = strMsg & " -Parameter Info: " & strPInfo

	strCode = t_object.StatusCode
	If strCode <> "" Then strMsg = strMsg & " -Status: " & strCode

	WMIErr = strMsg

	Set t_object = Nothing

	Err.Clear

End Function

Class IntData

	Public WshShell
	Public ISA
	Public ISAArray
	Public Server
	Public IntIP
	Public IAA
	Public Ver
	Public MsgTitle
	Public Msg
	Public Unowned
	Public NotLAT
	Public Changed
	Public Nada
	Public Quit

	Private Ask

	Sub Class_Initialize

		Ver = "1.3"	'define the program version number
		MsgTitle = "ISA Server IntraArrayAddress correction utility, version " & Ver

		'Create the root ect
		Set WshShell = CreateObject("WScript.Shell")
		Set ISA = CreateObject("FPC.Root")

		'Make sure it's current data
		ISA.Refresh

		'Find where we live
		Set ISAArray = ISA.Arrays.GetContainingArray
		Set Server = ISAArray.Servers.GetContainingServer

		'Let's get the current IAA entry
		IAA = Server.IntraArrayAddress
		IntIP = IAA

		Ask = vbCrLf & vbCrLf & "Please enter a proper IP address for this server."
		Unowned = " is not bound to this server." & Ask
		NotLAT = " is not part of the LAT subnet." & Ask
		Changed = "The ISA IntraArrayAddress has been corrected..." 
		Nada = " There was Nothing to do so I didn't do it..."
		Quit = "Are you sure you want to quit?"

	End Sub

	Sub Class_Terminate

		Set ISA = Nothing
		Set WshShell = Nothing
	
	End Sub
	
End Class
