' ***********************************************************************************
' *** Taken from Configuring ISA Server 2004 by Tom Shinder
' *** Page 576
' ***********************************************************************************
' *** CHANGES THAT NEED TO BE MADE BEFORE RUNNING
' *** Find the line: Set DomainNameSet = DomainNameSets.Item("Domains")
' *** Change Domains to the name of the Domain Name Set
' ***
' *** Find the line: Set DomainsFile = FileSys.OpenTextFile("domains.txt", 1)
' *** Change domain.txt to the name of the text file.
' ***********************************************************************************

Set Isa = CreateObject("FPC.Root")
Set CurArray = Isa.GetContainingArray
Set RuleElements = CurArray.RuleElements
Set DomainNameSets = RuleElements.DomainNameSets
Set DomainNameSet = DomainNameSets.Item("Domains")
Set FileSys = CreateObject("Scripting.FileSystemObject")
Set DomainsFile = FileSys.OpenTextFile("domains.txt", 1)
For i = 1 to DomainNameSet.Count
	DomainNameSet.Remove 1
Next
Do While DomainsFile.AtEndOfStream <> True
	DomainNameSet.Add DomainsFile.ReadLine
Loop
WScript.Echo "Saving..."
CurArray.Save
WScript.Echo "Done."
