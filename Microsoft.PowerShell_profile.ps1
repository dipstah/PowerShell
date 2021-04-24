# ==============================================================================================
# 
# Microsoft PowerShell Source File -- Created with SAPIEN Technologies PrimalScript 2007
# 
# NAME: 
# 
# AUTHOR: Mike White
# DATE  : 1/16/2008
# 
# COMMENT: Powershell Profile uses go commands to launch freaquently used applications. 
#	Functions are loaded with from the Functions directory located within the profileDirectory  
# 
# ==============================================================================================

$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal $identity
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$psVersion = $PSVersionTable.PSVersion

$Sysutil = "$env:SystemDrive\Sysutil"

## If so and the current host is a command line, then change to red color 
## as warning to user that they are operating in an elevated context
#if (($host.Name -match "ConsoleHost") -and ($isAdmin))
#{
#	$host.UI.RawUI.BackgroundColor = "DarkRed"
#	$host.PrivateData.ErrorBackgroundColor = "White"
#	$host.PrivateData.ErrorForegroundColor = "DarkRed"
#	Clear-Host
#}

#########################################################
#Snapins and modules
import-module activedirectory
if (Test-Path -Path "C:\Program Files (x86)\ConfigMgr Console\bin\ConfigurationManager.psd1")
{
	Import-Module "C:\Program Files (x86)\ConfigMgr Console\bin\ConfigurationManager.psd1"
}

########################################################

########################################################
# Aliases
# Set UNIX-like aliases for the admin command, so sudo <command> will run the command
# with elevated rights. 
Set-Alias -Name su -Value admin
Set-Alias -Name sudo -Value admin
set-alias -Name wide -Value Format-Wide
Set-Alias -Name open -Value o
########################################################

########################################################
# Helper Functions
function ff ([string]$glob) { get-childitem -recurse -include $glob }
function reboot { shutdown /r /t 0 }
function halt { shutdown /s /t 0 }
function rmd ([string]$glob) { remove-item -recurse -force $glob }
function whoami { (get-content env:\userdomain) + "\" + (get-content env:\username); }
function strip-extension ([string]$filename) { [system.io.path]::getfilenamewithoutextension($filename) }
function cd... { Set-Location ..\.. }
function cd.... { Set-Location ..\..\.. }
########################################################

########################################################
# Import functions form network share
$topicsToImport = "SCCM", "Generial"
$rootFunctionDir = "\\share\PowerShell\FunctionLibrary"
$topicDirs = Get-ChildItem $rootFunctionDir | Where-Object { $_.mode -match "d" }
foreach ($dir in $topicDirs)
{
	If ($topicsToImport -contains $dir.name)
	{
		$scriptDir = New-Object -TypeName "System.IO.DirectoryInfo" -ArgumentList ($dir.FullName)
		foreach ($file in $scriptDir.GetFiles("*.ps*"))
		{
			If ($file.FullName -like "*.psm1")
			{
				Import-Module $file.FullName
			}
			Else
			{
				.$file.FullName
			}
		}
	}
}
########################################################

########################################################
#Load Local Functions
$profileDir = Split-Path $Profile -Parent
$functionDir = New-Object -TypeName "System.IO.DirectoryInfo" -ArgumentList (Join-Path $profileDir 'Functions')
If (Test-Path -Path $functionDir)
{
	Set-Location $profileDir
	foreach ($file in $functionDir.GetFiles("*.ps1"))
	{
		. $file.FullName
	}
	If ($functionDir.GetDirectories())
	{
		If ($psVersion.Major -eq 7)
		{
			foreach ($folder in $functionDir.GetDirectories())
			{
				$functionFolder = "$folder"
				foreach ($file in (Get-ChildItem -Path $functionFolder -Filter "*.ps1"))
				{
					. $file.FullName
				}
			}
		}
		Else
		{
			foreach ($folder in $functionDir.GetDirectories())
			{
				$functionFolder = "$functionDir\$folder"
				foreach ($file in (Get-ChildItem -Path $functionFolder -Filter "*.ps1"))
				{
					. $file.FullName
				}
			}
		}
	}
}
########################################################

#######################################################
# Prompt
# Find out if the current user identity is elevated (has admin rights)

function prompt
{
	$specialChar = [Char]0x25ba
	$UserName = $identity.Name
	if ($isAdmin)
	{
		$color = "Red"
		$title = "**ADMIN** - $UserName - " + (get-location).Path;
		$promptText = ("PS # ")
		Write-Host $promptText -ForegroundColor $color -NoNewLine
	}
	else
	{
		$color = "Green"
		$title = "$UserName - " + (get-location).Path;
		$promptText = ("PS " + "$ ")
		Write-Host $promptText -NoNewLine
	}
	Write-Host $specialChar -ForegroundColor $color -NoNewline
	$host.UI.RawUI.WindowTitle = $title;
	return " "
}
########################################################

########################################################
# Simple function to start a new elevated process. If arguments are supplied then 
# a single command is started with admin rights; if not then a new admin instance
# of PowerShell is started.
function admin
{
	param
	(
		[parameter(Mandatory = $true)]
		[ValidateSet("pwsh", "wpwsh")]
		[string]
		$Type = "wpwsh"
	)
	if ($Type -eq "pwsh")
	{
		$argList = "& '" + $args + "'"
		Start-Process "C:\Program Files\PowerShell\7\pwsh.exe" -Verb runAs
	}
	if ($Type -eq "wpwsh")
	{
		Start-Process "PowerShell" -Verb runAs
	}
}
########################################################

########################################################
# 'go' command and targets
$GLOBAL:start_locations = @{ }
if ($GLOBAL:start_locations -eq $null)
{
	$GLOBAL:start_locations = @{ };
}

function o ([string]$location, $args)
{
	if ($start_locations.ContainsKey($location))
	{
		#Set-Location $go_locations[$location];
		#Invoke-Item $start_locations[$location];
		Start-Process -FilePath $start_locations[$location];
	}
	else
	{
		Write-Output "The following locations are defined:";
		Write-Output $start_locations;
	}
}
$start_locations.Add("admin", "c:\sysutil\bin\admin.msc")
$start_locations.Add("cfgMGR", "C:\Program Files (x86)\ConfigMgr Console\bin\Microsoft.ConfigurationManagement.exe")
$start_locations.Add("sqlmgmt", "C:\Program Files (x86)\Microsoft SQL Server Management Studio 18\Common7\IDE\Ssms.exe")
$start_locations.Add("FlySpeed", "C:\Program Files\ActiveDBSoft\FlySpeed SQL Query\FlySpeed SQL Query.exe")
$start_locations.Add("asg", "$env:LOCALAPPDATA\Microsoft\AppV\Client\Integration\833B6AF5-D8E2-441C-A7BB-93AB384A07A5\Root\VFS\ProgramFilesX86\ASG-Remote Desktop 2017\ASGRD.exe")
$start_locations.Add("pss", "C:\Program Files\SAPIEN Technologies, Inc\PowerShell Studio 2021\PowerShell Studio.exe")
$start_locations.Add("msedge", "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe")
########################################################

########################################################
# 'go' command and targets
$GLOBAL:go_locations = @{ }
if ($GLOBAL:go_locations -eq $null)
{
	$GLOBAL:go_locations = @{ }
}

function go ([string]$location)
{
	if ($go_locations.ContainsKey($location))
	{
		set-location $go_locations[$location];
	}
	else
	{
		write-output "The following locations are defined:";
		write-output $go_locations;
	}
}
$go_locations.Add("home", (get-item ([environment]::GetFolderPath("MyDocuments"))).Parent.FullName)
$go_locations.Add("desktop", [environment]::GetFolderPath("Desktop"))
$go_locations.Add("dl", (Join-Path ($env:USERPROFILE) "Downloads"))
$go_locations.Add("docs", [environment]::GetFolderPath("MyDocuments"))
$go_locations.Add("scripts", (Join-Path ([environment]::GetFolderPath("MyDocuments")) "WindowsPowerShell"))
$go_locations.Add("recent", [environment]::GetFolderPath("Recent"))
$go_locations.Add("sysutil", $Sysutil)
########################################################

Set-Location $Sysutil
