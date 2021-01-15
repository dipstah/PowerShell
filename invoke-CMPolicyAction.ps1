

function Invoke-CMPolicyAction {
	<#
	.SYNOPSIS
		Sends policy actions against a remote computer.

	.DESCRIPTION
		A detailed description of the function.

	.PARAMETER  ComputerName
		The name of the computer which will receive the policy action.

	.PARAMETER  Policy
		The action to be performed. 

	.EXAMPLE
		Invoke-dvnPolicyAction -ComputerName {computername} -Policy MachinePolicy

		This will cause the computer to request the SCCM Client Machine Policy from the SCCM Managment Point server. 


	.EXAMPLE
		Invoke-dvnPolicyAction -ComputerName {computername} -Policy SoftwareUpdatePolicy
			*WAIT A FEW MINUTES*
		Invoke-dvnPolicyAction -ComputerName {computername} -Policy SoftwareUpdateEvaluation

		These two policies, performed in this order, will cause a computer to check for new update requirements, and then to evaluate
		whether they are due to be installed now. 

	.EXAMPLE
		Invoke-dvnPolicyAction -ComputerName {computername} -Policy SoftwareUpdateReportBack

		This command instructs the computer to report its patch status back to CM so that reports can show current and accurate 
		information. Note, however, that multiple processes within CM can cause reporting to be delayed. The deployment data may
		need to be summarized, and the database may need to pull updated information before the console or reports are fully accurate. 
		Patience is required. 

	.EXAMPLE
		Invoke-dvnPolicyAction -ComputerName {computername} -Policy SoftwareUpdateINSTALLATION -Confirm

		The SofwareUpdateINSTALLATION policy will ignore any maintenance windows or deployment deadlines and initiate 
		an immediate installation of pending patches. To prevent accidental trigger, a confirmation is required. If 
		no -Confirm switch is specified in the command, the script will prompt for confirmation:

		Invoke-dvnPolicyAction -ComputerName {computername} -Policy SoftwareUpdateINSTALLATION

		"Are you sure you want to force updates to INSTALL, ignoring all maintenance windows and schedules? (y/n*):"

	.INPUTS
		System.String,System.Int32

	.OUTPUTS
		System.String

	.NOTES
		Most policies may be invoked without introducing new activity, as long as the policy itself does not trigger action. The exception to 
		that is the Software Update Installation policy. That policy will ignore any maintenance windows or deployment deadlines and initiate 
		an immediate installation of pending patches. 

	.LINK
		about_functions_advanced

	.LINK
		about_comment_based_help

#>
	
Param (
	[parameter(Mandatory=$true)]
	[string]$ComputerName,
	
	[Parameter(Mandatory=$true)]	
	[ValidateSet("MachinePolicy","SoftwareUpdatePolicy","SoftwareUpdateEvaluation","ApplicationDeploymentPolicy","SoftwareMeteringPolicy","UserPolicy","SoftwareUpdateReportBack","SoftwareUpdateINSTALLATION","HardwareInventory")]
	[string]$Policy,
	
	[switch]$Confirm = $false
)


	if (Test-Connection -ComputerName $ComputerName -count 1  -ErrorAction SilentlyContinue) {
		$ResultPing = $true
	
		Try {
			$SMSCli = [wmiclass] "\\$ComputerName\root\ccm:SMS_Client"

			if ($Policy -eq "MachinePolicy") {
				# Machine Policy
				$SMSCli.TriggerSchedule("{00000000-0000-0000-0000-000000000021}") | Out-Null
				$ResultPolicy = $true
				
				}
			if ($Policy -eq "SoftwareUpdatePolicy") {
				# Software Update Policies
				$SMSCli.TriggerSchedule("{00000000-0000-0000-0000-000000000113}") | Out-Null
				$SMSCli.TriggerSchedule("{00000000-0000-0000-0000-000000000108}") | Out-Null
				$ResultPolicy = $true
				
				}

			if ($Policy -eq "SoftwareUpdateEvaluation") {
				# Software Update State Evaluation
				$SMSCli.TriggerSchedule("{00000000-0000-0000-0000-000000000108}") | Out-Null
				$ResultPolicy = $true
				
				}

			if ($Policy -eq "HardwareInventory") {
				#Application Deployment Evaluation Policy
				$SMSCli.TriggerSchedule("{00000000-0000-0000-0000-000000000001}") | Out-Null
				$ResultPolicy = $true
				
				}



			if ($Policy -eq "ApplicationDeploymentPolicy") {
				#Application Deployment Evaluation Policy
				$SMSCli.TriggerSchedule("{00000000-0000-0000-0000-000000000121}") | Out-Null
				$ResultPolicy = $true
				
				}
			if ($Policy -eq "SoftwareMeteringPolicy") {
				#Software Metering Usage Report Cycle Policy
				$SMSCli.TriggerSchedule("{00000000-0000-0000-0000-000000000106}") | Out-Null
				$SMSCli.TriggerSchedule("{00000000-0000-0000-0000-000000000031}") | Out-Null
				$ResultPolicy = $true
				
				}
			if ($Policy -eq "UserPolicy") {
				#Current logged in User Policy
				$ErrorExplanation = "This will fail if no user is logged in."
				$sid = ( get-wmiobject -ComputerName $ComputerName -query "SELECT UserSID FROM CCM_UserLogonEvents WHERE LogoffTime = NULL" -namespace "ROOT\ccm").UserSID.replace('-','_')[0] 
				if (-not $SID) {
					Write-Error "This will fail if no user is logged in." -ErrorAction 'Stop'
					}
				$sched=([wmi]"\\$ComputerName\root\ccm\Policy\$sid\ActualConfig:CCM_Scheduler_ScheduledMessage.ScheduledMessageID='{00000000-0000-0000-0000-000000000026}'")
				$sched.Triggers=@('SimpleInterval;Minutes=1;MaxRandomDelayMinutes=0')
				$sched.Put()  | Out-Null
				$ResultPolicy = $true
				
				}
			if ($Policy -eq "SoftwareUpdateReportBack") {
				# Report Software Update State back to the CM Management Point Server
				Invoke-Command -ComputerName $ComputerName -ErrorVariable RefreshCompliance -ErrorAction 'SilentlyContinue' -ScriptBlock {
					$SCCMUpdatesStore = New-Object -ComObject Microsoft.CCM.UpdatesStore
					$SCCMUpdatesStore.RefreshServerComplianceState()
					}
				$ResultPolicy = $true
				
				}
			if ($Policy -eq "SoftwareUpdateINSTALLATION") {
				#Software Update INSTALLATION will be triggered - CAUTION!
				if (-not $Confirm) {
					$ConfirmResponse = Read-Host "Are you sure you want to force updates to INSTALL, ignoring all maintenance windows and schedules? (y/n*)"
					If ($ConfirmResponse -eq "y") {
						([wmiclass]"\\$ComputerName\ROOT\ccm\ClientSDK:CCM_SoftwareUpdatesManager").InstallUpdates([System.Management.ManagementObject[]] (Get-WmiObject -Query 'SELECT * FROM CCM_SoftwareUpdate' -computername $computername -namespace "ROOT\ccm\ClientSDK")) | out-null
						}
					else {
						$ResultPolicy = $false
						Write-Error "Confirmation failed." -ea 'Stop'
						}
					}
				elseif ($Confirm -eq $true) {
					([wmiclass]"\\$ComputerName\ROOT\ccm\ClientSDK:CCM_SoftwareUpdatesManager").InstallUpdates([System.Management.ManagementObject[]] (Get-WmiObject -Query 'SELECT * FROM CCM_SoftwareUpdate' -computername $computername -namespace "ROOT\ccm\ClientSDK")) | out-null
					}
				$ResultPolicy = $true
				
				}

			# Try has succeeded without a Catch 
			Write-Host $ErrorExplanation
			$ResultPolicy = $true	
			}
		
		Catch { 
#			$ResultPolicy = $false
			}
		}
	else {
		$ResultPing = $false
		$ResultPolicy = $false
		$ResultCompliance = $false
		}

	
$Script:ReportBack = New-Object -TypeName PSObject
	$ReportBack | Add-Member -MemberType 'NoteProperty' -Name ComputerName -Value $ComputerName
	$ReportBack | Add-Member -MemberType 'NoteProperty' -Name Response -Value $ResultPing
	$ReportBack | Add-Member -MemberType 'NoteProperty' -Name Completed -Value $ResultPolicy
	$ReportBack | Add-Member -MemberType 'NoteProperty' -Name PolicyName -Value $Policy
#	$ReportBack | Add-Member -MemberType 'NoteProperty' -Name ComplianceState -Value $ResultCompliance

$ReportBack 
}
