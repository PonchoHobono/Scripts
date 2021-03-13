ComputerName = InputBox("Enter the name of the computer you wish to query")

set IPConfigSet = GetObject("winmgmts:{impersonationLevel=impersonate}!//"& ComputerName &"").ExecQuery("select IPAddress from Win32_NetworkAdapterConfiguration where IPEnabled=TRUE")

for each IPConfig in IPConfigSet
	if Not IsNull(IPConfig.IPAddress) then 
		for i=LBound(IPConfig.IPAddress) to UBound(IPConfig.IPAddress)
			WScript.Echo "IPAddress: " & IPConfig.IPAddress(i)
		next
	end if
next
