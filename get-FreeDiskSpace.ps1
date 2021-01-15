function get-DvnFreeDiskSpace
{
	
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory = $true, Position = 0)]
		[string]$ComputerName
	)
	
	$script:FreeDiskSpace = Get-WmiObject -ComputerName $ComputerName -Class Win32_LogicalDisk | Where-Object { $_.DriveType -eq "3" -and $_.DeviceID -Like "$ID*" } | Select-Object SystemName,
																																				  @{ Name = "Drive"; Expression = { ($_.DeviceID) } },
																																				  @{ Name = "Size (GB)"; Expression = { "{0:N1}" -f ($_.Size / 1gb) } },
																																				  @{ Name = "FreeSpace (GB)"; Expression = { "{0:N1}" -f ($_.Freespace / 1gb) } },
																																				  @{ Name = "PercentFree"; Expression = { "{0:P1}" -f ($_.FreeSpace / $_.Size) } } |
	Format-Table -AutoSize | Out-String
	Write-Output $FreeDiskSpace
	
}
