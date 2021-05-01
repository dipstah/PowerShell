<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2019 v5.6.160
	 Created on:   	7/30/2019 11:17 AM
	 Created by:   	SYSTEM
	 Organization: 	
	 Filename:     	
	===========================================================================
	.DESCRIPTION
		script used in MECM task sequence to run dcu-cli.exe for dell driver updates. 
#>


$Date = Get-Date
$LogLocation = "c:\temp\Logs\dcu"
$OSArchitecture = (Get-WmiObject -Class Win32_OperatingSystem | Select-Object OSArchitecture).OSArchitecture
$Model = (Get-WmiObject -Class Win32_ComputerSystem).Model

If ($OSArchitecture -eq "32-bit")
{
	$File = Get-ChildItem -Path "$env:ProgramFiles\Dell\CommandUpdate\" -Filter "dcu-cli.exe" -ErrorAction SilentlyContinue -Recurse
}
else
{
	$File = Get-ChildItem -Path "${env:ProgramFiles(x86)}\Dell\CommandUpdate\" -Filter "dcu-cli.exe" -ErrorAction SilentlyContinue -Recurse
}

$EXE = $File.FullName

If ($LogLocation[$LogLocation.Length - 1] -ne "\")
{
	$Location = $LogLocation + "\" + $Model
}
else
{
	$Location = $LogLocation + $Model
}
If ((Test-Path $LogLocation) -eq $false)
{
	New-Item -Path $LogLocation -ItemType Directory -Force | Out-Null
}
If ((Test-Path $Location) -eq $false)
{
	New-Item -Path $Location -ItemType Directory -Force | Out-Null
}
$Location += "\" + $env:COMPUTERNAME
If ((Test-Path $Location) -eq $true)
{
	Remove-Item -Path $Location -Recurse -Force
}
$Location = $Location + ".log"
$Log = "c:\temp\Logs\dcuUpdates" + $Date + ".Log"
$Log
$Arguments = "/applyUpdates -autoSuspendBitLocker=enable -outputLog=c:\Sysutil\Logs\DcuUpdates.log"

#Suspend-BitLocker -MountPoint c: -RebootCount 1 | Out-Null
$dcu = Start-Process -FilePath $EXE -ArgumentList $Arguments -Wait -Passthru
[string]$dcuExit = $dcu.ExitCode

switch ($dcuExit)
{
	0 {
		#exit 
		Write-Output "exit success 0"
		Add-Content -Path "$LogLocation\ExitCodes.log" -Value "success $dcuExit - $Date"
		Resume-BitLocker -MountPoint c: | Out-Null
		[System.Environment]::Exit(0)
	}
	1 {
		#Reboot Required
		Write-Output "exit reboot 3010"
		Add-Content -Path "$LogLocation\ExitCodes.log" -Value "Success reboot $dcuExit - $Date"
		#[System.Environment]::Exit(3010)
		[System.Environment]::Exit(0)
	}
	2 {
		#Fatal Error 
		Write-Output "exit fatal error 1"
		Add-Content -Path "$LogLocation\ExitCodes.log" -Value "BIOS Update or application require reboot - $dcuExit - $Date"
		Resume-BitLocker -MountPoint c: | Out-Null
		#[System.Environment]::Exit(3010)
		[System.Environment]::Exit(0)
	}
	3 {
		#Error 
		Write-Output "exit error 1"
		Add-Content -Path "$LogLocation\ExitCodes.log" -Value "error $dcuExit - $Date"
		Resume-BitLocker -MountPoint c: | Out-Null
		[System.Environment]::Exit(1)
	}
	4 {
		#Invalid System
		Write-Output "exit invalid system 1"
		Add-Content -Path "$LogLocation\ExitCodes.log" -Value "invalid system $dcuExit - $Date"
		Resume-BitLocker -MountPoint c: | Out-Null
		[System.Environment]::Exit(1)
	}
	5 {
		#Reboot Required
		Write-Output "exit reboot re-scan 3010"
		Add-Content -Path "$LogLocation\ExitCodes.log" -Value "Success reboot re-scan $dcuExit - $Date"
		#[System.Environment]::Exit(3010)
		[System.Environment]::Exit(0)
	}
	500 {
		#Reboot Required
		Write-Output "exit No Updates found"
		Add-Content -Path "$LogLocation\ExitCodes.log" -Value "Success No Updates found $dcuExit - $Date"
		[System.Environment]::Exit(0)
	}
	default
	{
		Write-Output "exit default 0"
		Resume-BitLocker -MountPoint c: | Out-Null
		Add-Content -Path "$LogLocation\ExitCodes.log" -Value "default success $dcuExit - $Date"
		[System.Environment]::Exit(0)
	}
}
