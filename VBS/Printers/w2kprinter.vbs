'**************************************************************************************************************************
'**************************************************************************************************************************
'*****                  Configure LPR Control Command For Windows 2000 Machine With A Raw Printer                     *****
'*****                  Created By: Patrick Hoban                                                                     *****
'*****                  HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Print\Monitors\LPR Port\Ports\<port>      *****
'**************************************************************************************************************************
'**************************************************************************************************************************
On Error Resume Next
vbPara=vbCRLF & vbCRLF
strExplain="This will configure the LPR control command." & vbPara & "You will be prompted to type in the port that the RAW"  & _ 
		vbPara & "printer is installed on. Only type the last two digits."
strTitle="Configure Raw Printer Port"

Dim strPort
Dim Sh
Set Sh = WScript.CreateObject("WScript.Shell")
ReportErrors "Creating Shell"

GetPort

if strPort<>" " then
	'Result = MsgBox(strPort, 65, strTitle)
	Test
else
	Result = msgbox("You didn't enter anything", 6, strTitle)
	GetPort
end if

'***TEST***
Sub Test
	B=Sh.RegRead (strPort)
	Result = MsgBox("Test", 6, strTitle)

	If Err.Number=0 Then 
		'Sh.RegDelete Key
		If Err.Number =0 Then 
			If silent<>"yes" Then MsgBox Key & " found", vbOKOnly + vbInformation, strTitle
		Else
			ReportErrors "?"
		End If
	Else
		If Err.Number=-2147024893 then 
			Err.Clear
			MsgBox strPort & " didn't exist", vbOKOnly + vbCritical, strTitle
		Else
			ReportErrors "Reading before Deleting Key"
		End If
	End If
End Sub
'***END TEST***



Sub GetPort
	strPort = InputBox ("Type in the port of the RAW printer." & vbPara & "10.10.10.xx", strTitle, strNamet1)
end Sub
