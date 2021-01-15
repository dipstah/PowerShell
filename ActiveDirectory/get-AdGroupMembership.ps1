function get-ADGroupMembership
{
<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2014 v4.1.61
	 Created on:   	7/30/2014 10:13 AM
	 Created by:   	Mike White
	 Organization: 	
	 Filename:get-AdGroupMembership
	 Version:
	 	1.1.4.20.15
		 Initial Script Creation
		1.2.5.21.15
		 re-write removed ADgroup search this just took to long. 
		 searching memberOf from the user object 
		 output to an object
	 
	===========================================================================
	.DESCRIPTION
		Powershell Function used to list the groups a user is a direct member of.  

	.PARAMETER userName
		Active Directory SamAccountName of user.

	.EXAMPLE
		get-AdGroupMemberShip -userName {username}
	
		UserName Group                                                                    DisplayName
		-------- -----                                                                    -----------
		{username}  allsubscribers08ed6e04                                                   White, Mike
	
		.EXAMPLE
		get-AdGroupMemberShip -userName {username}| select Group, DisplayName
	
		Display only Group and DisplayName

		Group                                                                    DisplayName
		-----                                                                    -----------
		allsubscribers08ed6e04                                                   White, Mike
		ch.test                                                                  White, Mike
	
		.EXAMPLE
		get-AdGroupMemberShip -userName {username} | select Group	
		
		Display Only Group
	
		Group
		-----
		allsubscribers
		ad.test
		ad.Win10.TestConfig
#>
	
	
	
	[CmdletBinding()]
	PARAM
	(
		[Parameter(Mandatory = $true, Position = 0)]
		[ValidateScript({ Get-ADUser -Identity $_ })]
		[string]$userName
	)
	
	$object = @()
	
	$userObj = Get-ADUser -Properties MemberOf, EmailAddress, Department, orgdistrict, DisplayName -Identity $userName
	$Groups = foreach ($Group in ($userObj.MemberOf)) { (get-adgroup $Group).name }
	$Groups = $Groups | sort
	foreach ($Group in $Groups)
	{
		$properties = @{
			"Group"  = $Group;
			"UserName"   = $userObj.SamAccountName;
			"DisplayName" = $userObj.DisplayName
		}
		$object += $object = New-Object –TypeName PSObject -Property $properties
	}
	$object
}
