' ***********************************************************************************
' *** Taken from Configuring ISA Server 2004 by Tom Shinder
' *** Page 575
' ***********************************************************************************
' *** CHANGES THAT NEED TO BE MADE BEFORE RUNNING
' *** Find the line: Set URLSet = URLSets.Item("Urls")
' *** Change Urls to the name of the URL Set
' ***
' *** Find the line: Set UrlsFile = FileSys.OpenTextFile("urls.txt", 1)
' *** Change urls.txt to the name of the text file.
' ***********************************************************************************

Set Isa = CreateObject("FPC.Root")
Set CurArray = Isa.GetContainingArray
Set RuleElements = CurArray.RuleElements
Set URLSets = RuleElements.URLSets
Set URLSet = URLSets.Item("Urls")
Set FileSys = CreateObject("Scripting.FileSystemObject")
Set UrlsFile = FileSys.OpenTextFile("urls.txt", 1)
For i = 1 to URLSet.Count
	URLSet.Remove 1
Next
Do While UrlsFile.AtEndOfStream <> True
	URLSet.Add UrlsFile.ReadLine
Loop
WScript.Echo "Saving..."
CurArray.Save
WScript.Echo "Done."