' I did not write this. Got it from somewhere else but cannot recall.

Set fso = CreateObject("Scripting.FileSystemObject")
Set objAutomaticUpdates = CreateObject("Microsoft.Update.AutoUpdate")
objAutomaticUpdates.EnableService
objAutomaticUpdates.DetectNow

Set objSession = CreateObject("Microsoft.Update.Session")
Set objSearcher = objSession.CreateUpdateSearcher()
Set objResults = objSearcher.Search("IsInstalled=0 and Type='Software'")
Set colUpdates = objResults.Updates

Set objUpdatesToDownload = CreateObject("Microsoft.Update.UpdateColl")
intUpdateCount = 0
For i = 0 to colUpdates.Count - 1
 intUpdateCount = intUpdateCount + 1
 Set objUpdate = colUpdates.Item(i)
 objUpdatesToDownload.Add(objUpdate)
Next

If intUpdateCount = 0 Then
 WScript.Quit
Else
 Set objDownloader = objSession.CreateUpdateDownloader()
 objDownloader.Updates = objUpdatesToDownload
 objDownloader.Download()

 Set objInstaller = objSession.CreateUpdateInstaller()
 objInstaller.Updates = objUpdatesToDownload
 Set installationResult = objInstaller.Install()
		
 Set objSysInfo = CreateObject("Microsoft.Update.SystemInfo")
 If objSysInfo.RebootRequired Then
  Set objWMIService = GetObject ("winmgmts:{impersonationLevel=impersonate(Shutdown)}!\\localhost\root\cimv2")
  Set colOperatingSystems = objWMIService.ExecQuery ("Select * from Win32_OperatingSystem")
  For Each objOperatingSystem in colOperatingSystems
   objOperatingSystem.Reboot()
  Next
 End If
End If
