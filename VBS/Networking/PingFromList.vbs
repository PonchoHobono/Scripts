On Error Resume Next
Const ForAppending = 8
Set objShell = WScript.CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")
Set PingFile = objFSO.OpenTextFile("C:\temp\track_sheet.txt")
Set objTextFile = objFSO.OpenTextFile _
("C:\temp\PowerOn_log.txt", ForAppending, True)

Do Until PingFile.AtEndofStream
strComputer = PingFile.Readline
Set objExecObject = objShell.Exec("cmd /c ping -n 1 -w 300 " & strComputer)
Do While Not objExecObject.StdOut.AtEndOfStream
strText = objExecObject.StdOut.ReadLine()
If Instr(strText, "Reply") > 0 Then
objTextFile.WriteLine(strComputer)
Exit Do
End If
Loop
Loop
