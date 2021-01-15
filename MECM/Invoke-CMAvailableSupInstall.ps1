
function Invoke-CMAvailableSupInstall
{
<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2017 v5.4.145
	 Created on:   	08/20/2020
	 Created by:   	Mike White
	 Organization: 	
	 Filename: Invoke-CMAvailableSupInstall
	 Version: 1.0.8.20.20
	 Initial Script Function
	===========================================================================
	.DESCRIPTION
		PowerShell Function to connect to computer(s) and get or install SoftwareUpdates,Patches. 
	
	.PARAMETER ComputerName
		Name of Computer or Computers to invoke command on.
	
	.PARAMETER Action
		Action to perform Get or Install
	
	.EXAMPLE 
		Invoke-CMAvailableSupInstall -Computername {computername} -Action get
	
		Connect to Computer and get available Software Updates. returns Evaluation State, ComputerName, Update Name. 

		EvaluationState               ComputerName  Update
		---------------               ------------  ------
		JobStatePendingSoftReboot = 8 {computername} 2020-08 Cumulative Update for Windows Server 2016 for x64-based Systems (KB4571694)
	
	.EXAMPLE
		Invoke-CMAvailableSupInstall -Computername {computername} -Action Install
	
		Connect to Computer and Invoke Software Update Installs. 
	
	.EXAMPLE
		Invoke-CMAvailableSupInstall -Computername {computername},{computername},{computername} -Action get
	
		Connect to Multiple Computers and get Update List with Evaluation States. 
	
	.EXAMPLE
	
		Invoke-CMAvailableSupInstall -Computername {computername},{computername},{computername} -Action Install
	
		Connect to Multiple Computers and invoke Software Update Installs. 
	
	
#>
	[CmdletBinding()]
	Param
	(
		[String[]][Parameter(Mandatory = $True, Position = 1)]
		[ValidateScript({ Get-ADComputer -Identity $_ })]
		$ComputerName,
		[String][Parameter(Mandatory = $True, Position = 2)]
		[ValidateSet("Install","Get")]
		$Action
	)
	Begin
	{
		$AppEvalState0 = "0"
		$AppEvalState1 = "1"
		$ApplicationClass = [WmiClass]"root\ccm\clientSDK:CCM_SoftwareUpdatesManager"
		$properties = @()
		$object = @()
	}
	
	Process
	{
		If (Test-Connection -ComputerName $ComputerName -Count 1 -ErrorAction SilentlyContinue)
		{
			If ($Action -eq "Install")
			{
				Foreach ($Computer in $ComputerName)
				{
					$MissingUpdates  = (Get-WmiObject -Namespace "root\ccm\clientSDK" -Class CCM_SoftwareUpdate -ComputerName $Computer | Where-Object { $_.EvaluationState -like "*$($AppEvalState0)*" -or $_.EvaluationState -like "*$($AppEvalState1)*" })
					Invoke-WmiMethod -Class CCM_SoftwareUpdatesManager -Name InstallUpdates -ArgumentList ( ,$MissingUpdates ) -Namespace root\ccm\clientsdk -ComputerName $Computer
				}
			}	
			If ($Action -eq "Get")
			{
				Foreach ($Computer in $ComputerName)
				{
					$MissingUpdates  = (Get-WmiObject -Namespace "root\ccm\clientSDK" -Class CCM_SoftwareUpdate -ComputerName $Computer | Where-Object { $_.EvaluationState -like "*$($AppEvalState)*"})
					Foreach ($Update in $MissingUpdates )
					{
						switch ($Update.EvaluationState)
						{
							0 { $EvalState = "0 = None" }
							1  { $EvalState = "1 = Available" }
							2  { $EvalState = "2 = Submitted" }
							3  { $EvalState = "3 = Detecting " }
							4  { $EvalState = "4 = PreDownload" }
							5  { $EvalState = "5 = Downloading" }
							6  { $EvalState = "6 = WaitInstall" }
							7  { $EvalState = "7 = Installing" }
							8  { $EvalState = "8 = PendingSoftReboot" }
							9  { $EvalState = "9 = PendingHardReboot" }
							10  { $EvalState = "10 = WaitReboot" }
							11  { $EvalState = "11 = Verifying" }
							12  { $EvalState = "12 = Install Complete" }
							13  { $EvalState = "13 = Error" }
							14  { $EvalState = "14 = WaitServiceWindow" }
							15  { $EvalState = "15 = WaitUserLogon" }
							16  { $EvalState = "16 = WaitUserLogoff" }
							17  { $EvalState = "17 = WaitJobUserLogon" }
							18  { $EvalState = "18 = WaitUserReconnect" }
							19  { $EvalState = "19 = PendingUserLogoff" }
							20  { $EvalState = "20 = PendingUpdate" }
							21  { $EvalState = "21 = WaitingRetry" }
							22  { $EvalState = "22 = WaitPresModeOff" }
							23  { $EvalState = "23 = WaitForOrchestration" }
							default { $EvalState = "Unknown" }
						}
						$properties = @{
							"EvaluationState" = $EvalState;
							"UpdateName"		  = $Update.Name;
							"ComputerName"    = $Computer;
							"PercentComplete" = $Update.PercentComplete;
							"Description"	  = $Update.Description;
							"ArticleID"	      = $Update.ArticleID;
							"BulletinID"	  = $Update.BulletinID;
							"ErrorCode"	      = $Update.ErrorCode
						}
						$object += $object = New-Object -TypeName PSObject -Property $properties
					}
				}
			}
		}
		Else
		{
			Write-Error -Message "Unable to connect to $ComputerName" -RecommendedAction "verifiy Computer Name and that computer is online" -CategoryReason "Test Connection Failed"
		}
	}
	End
	{
		Write-Output $object
	}
}
