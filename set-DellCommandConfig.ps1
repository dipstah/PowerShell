
$Date = Get-Date
$LogLocation = "c:\temp\dcu"
$OSArchitecture = (Get-WmiObject -Class Win32_OperatingSystem | Select-Object OSArchitecture).OSArchitecture

[xml]$xml = @'
<Configuration>
  <Group Name="Settings" Version="4.1.0" TimeSaved="5/18/2021 9:47:08 AM (UTC -5:00)">
    <Group Name="General">
      <Property Name="SettingsModifiedTime">
        <Value>5/18/2021 9:46:50 AM</Value>
      </Property>
      <Property Name="DownloadPath" Default="ValueIsDefault" />
      <Property Name="CustomCatalogPaths" Default="ValueIsDefault" />
      <Property Name="EnableDefaultDellCatalog" Default="ValueIsDefault" />
      <Property Name="UserConsent" Default="ValueIsDefault" />
      <Property Name="SuspendBitLocker">
        <Value>true</Value>
      </Property>
      <Group Name="CustomProxySettings">
        <Property Name="UseDefaultProxy" Default="ValueIsDefault" />
        <Property Name="Server" Default="ValueIsDefault" />
        <Property Name="Port" Default="ValueIsDefault" />
        <Property Name="UseAuthentication" Default="ValueIsDefault" />
      </Group>
    </Group>
    <Group Name="Schedule">
      <Property Name="ScheduleMode">
        <Value>Daily</Value>
      </Property>
      <Property Name="Time" Default="ValueIsDefault" />
      <Property Name="DayOfWeek" Default="ValueIsDefault" />
      <Property Name="DayOfMonth" Default="ValueIsDefault" />
      <Property Name="AutomationMode">
        <Value>ScanDownloadApplyNotify</Value>
      </Property>
      <Property Name="ScheduledExecution" Default="ValueIsDefault" />
      <Property Name="RebootWait">
        <Value>OneHour</Value>
      </Property>
    </Group>
    <Group Name="UpdateFilter">
      <Property Name="FilterApplicableMode" Default="ValueIsDefault" />
      <Group Name="RecommendedLevel">
        <Property Name="IsCriticalUpdatesSelected" Default="ValueIsDefault" />
        <Property Name="IsRecommendedUpdatesSelected" Default="ValueIsDefault" />
        <Property Name="IsOptionalUpdatesSelected" Default="ValueIsDefault" />
        <Property Name="IsSecurityUpdatesSelected" Default="ValueIsDefault" />
      </Group>
      <Group Name="UpdateType">
        <Property Name="IsDriverSelected" Default="ValueIsDefault" />
        <Property Name="IsApplicationSelected" Default="ValueIsDefault" />
        <Property Name="IsBiosSelected" Default="ValueIsDefault" />
        <Property Name="IsFirmwareSelected" Default="ValueIsDefault" />
        <Property Name="IsUtilitySelected" Default="ValueIsDefault" />
        <Property Name="IsUpdateTypeOtherSelected" Default="ValueIsDefault" />
      </Group>
      <Group Name="DeviceCategory">
        <Property Name="IsAudioSelected" Default="ValueIsDefault" />
        <Property Name="IsChipsetSelected" Default="ValueIsDefault" />
        <Property Name="IsInputSelected" Default="ValueIsDefault" />
        <Property Name="IsNetworkSelected" Default="ValueIsDefault" />
        <Property Name="IsStorageSelected" Default="ValueIsDefault" />
        <Property Name="IsVideoSelected" Default="ValueIsDefault" />
        <Property Name="IsDeviceCategoryOtherSelected" Default="ValueIsDefault" />
      </Group>
    </Group>
    <Group Name="AdvancedDriverRestore">
      <Property Name="IsCabSourceDell" Default="ValueIsDefault" />
      <Property Name="CabPath" Default="ValueIsDefault" />
      <Property Name="IsAdvancedDriverRestoreEnabled">
        <Value>true</Value>
      </Property>
    </Group>
  </Group>
</Configuration>
'@

If ($OSArchitecture -eq "32-bit")
{
	$File = Get-ChildItem -Path "$env:ProgramFiles\Dell\CommandUpdate\" -Filter "dcu-cli.exe" -ErrorAction SilentlyContinue -Recurse
}
else
{
	$File = Get-ChildItem -Path "${env:ProgramFiles(x86)}\Dell\CommandUpdate\" -Filter "dcu-cli.exe" -ErrorAction SilentlyContinue -Recurse
}

$EXE = $File.FullName

If ((Test-Path $LogLocation) -eq $false)
{
	New-Item -Path $LogLocation -ItemType Directory -Force | Out-Null
}
$xml.Save("$LogLocation\DellCommandUpdateSettingsInstallNotify.xml")
$Arguments = "/Configure -importsettings=C:\temp\dcu\DellCommandUpdateSettingsInstallNotify.xml"

$dcu = Start-Process -FilePath $EXE -ArgumentList $Arguments -Wait -Passthru
[string]$dcuExit = $dcu.ExitCode

switch ($dcuExit)
{
	0 {
		#exit 
		Write-Output "exit success 0"
		Add-Content -Path "$LogLocation\ExitCodes.log" -Value "success $dcuExit - $Date"
		#[System.Environment]::Exit(0)
	}
	1 {
		#Reboot Required
		Write-Output "exit reboot 3010"
		Add-Content -Path "$LogLocation\ExitCodes.log" -Value "Success reboot $dcuExit - $Date"
		#[System.Environment]::Exit(3010)
		#[System.Environment]::Exit(0)
	}
	2 {
		#Fatal Error 
		Write-Output "exit fatal error 1"
		Add-Content -Path "$LogLocation\ExitCodes.log" -Value "BIOS Update or application require reboot - $dcuExit - $Date"
		#[System.Environment]::Exit(3010)
		#[System.Environment]::Exit(0)
	}
	3 {
		#Error 
		Write-Output "exit error 1"
		Add-Content -Path "$LogLocation\ExitCodes.log" -Value "error $dcuExit - $Date"
		#[System.Environment]::Exit(1)
	}
	4 {
		#Invalid System
		Write-Output "exit invalid system 1"
		Add-Content -Path "$LogLocation\ExitCodes.log" -Value "invalid system $dcuExit - $Date"
		#[System.Environment]::Exit(1)
	}
	5 {
		#Reboot Required
		Write-Output "exit reboot re-scan 3010"
		Add-Content -Path "$LogLocation\ExitCodes.log" -Value "Success reboot re-scan $dcuExit - $Date"
		#[System.Environment]::Exit(3010)
		#[System.Environment]::Exit(0)
	}
	500 {
		#Reboot Required
		Write-Output "exit No Updates found"
		Add-Content -Path "$LogLocation\ExitCodes.log" -Value "Success No Updates found $dcuExit - $Date"
		#[System.Environment]::Exit(0)
	}
	default
	{
		Write-Output "exit default 0"
		Add-Content -Path "$LogLocation\ExitCodes.log" -Value "default success $dcuExit - $Date"
		#[System.Environment]::Exit(0)
	}
}
