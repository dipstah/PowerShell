<#	
	.NOTES
	===========================================================================
	 Created on:   	7/29/2022 9:04 AM
	 Created by:   	White, Mike dipstah@dippydawg.net
	 Organization: 	
	 Filename: Update-DVNLockScreen

		===========================================================================
	.DESCRIPTION
		Update the Lock screen with corporate communications images.
    script determins resolution then sets the image with the appropriate resolution.
    Script is executed via Ivanti Environment Manager when screen is locked 
    you could monitor the eventlog for screenlocks and or use a scheduled task. 
#>

Begin {
    #Function for Logging
    function LogWrite([string]$LogString) {
        try {
            Add-content $script:LogFile -value "$(Get-Date -Format yyyy-MM-dd_HH:mm:ss) $LogString" -force -ErrorAction Stop
        }
        catch {
            Write-Warning $_.Exception.Message
        }
    }

    #Define log file name and location
    $LogPath = "$env:SystemDrive\Sysutil\Logs"
    $LogFileName = "SetLockScreen.log"
    $LogFile = "$LogPath\$LogFileName"
    $LogFileSize = ((Get-Item -Path $LogFile).length / 1MB)
    IF ($LogFileSize -gt 1) {
        Remove-Item -Path $LogFile
        LogWrite("LogFile Created")
    }
    #Log that screen was locked
    LogWrite("Screen Locked")
    #Restry Path for the Lockscreen setting
    $strPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization"
    #Path to where images are located. 
    $LockScreenPath = "c:\Windows\Resources\Themes\LockScreen"
}
Process {
    #get resolution from primary monitor
    Add-Type -AssemblyName System.Windows.Forms
    $ScreenRes = "{0}x{1}" -f [System.Windows.Forms.SystemInformation]::PrimaryMonitorSize.Width, [System.Windows.Forms.SystemInformation]::PrimaryMonitorSize.Height

    #filename will begin with the following and search for each resolution. 
    #support for multiple files with the same resolution for random rotation when the screen locks. 
    Try{
        $LockScreens = Get-ChildItem -Path "$LockScreenPath" -Recurse -Filter *.jpg
    }Catch{
        #Log the error message
        LogWrite("Error retrieving lock screen images: $_.Exception.Message")
    }

    #Supported image Resolutions
    $res1280X800 = "1280X800"
    $res1536X960 = "1536X960"
    $res1920X1080 = "1920X1080"
    $res1920X1200 = "1920X1200"
    $res1920X1280 = "1920X1280"
    $res2048X1152 = "2048X1152"
    $res2560X1440 = "2560X1440"
    $res2560X1600 = "2560X1600"
    $res3072X1728 = "3072X1728"
    $res3840X1600 = "3840X1600"
    $res3840X2160 = "3840X2160"

    #Select Images based on current screen resolution
    switch ($ScreenRes) {
        "1280X800" {
            $LockScreens1280X800 = $LockScreens | Where-Object { $_.Name -like "LockScreen_*$res1280X800.jpg" }
            $LockScreen = get-random -InputObject $LockScreens1280X800.FullName
            Set-ItemProperty -Path $strPath -Name LockScreenImage -value $LockScreen
            LogWrite("LockScreen = $LockScreen")
        }
        "1536X960" {
            $LockScreens1536X960 = $LockScreens | Where-Object { $_.Name -like "LockScreen_*$res1536X960.jpg" }
            $LockScreen = get-random -InputObject $LockScreens1536X960.FullName
            Set-ItemProperty -Path $strPath -Name LockScreenImage -value $LockScreen
            LogWrite("LockScreen = $LockScreen")
        }
        "1920X1080" {
            $LockScreens1920X1080 = $LockScreens | Where-Object { $_.Name -like "LockScreen_*$res1920X1080.jpg" }
            $LockScreen = get-random -InputObject $LockScreens1920X1080.FullName
            Set-ItemProperty -Path $strPath -Name LockScreenImage -value $LockScreen
            LogWrite("LockScreen = $LockScreen")
        }
        "1920X1200" {
            $LockScreens1920X1200 = $LockScreens | Where-Object { $_.Name -like "LockScreen_*$res1920X1200.jpg" }
            $LockScreen = get-random -InputObject $LockScreens1920X1200.FullName
            Set-ItemProperty -Path $strPath -Name LockScreenImage -value "$ImagePath$LockScreen"
            LogWrite("LockScreen = $LockScreen")
        }
        "1920X1280" {
            $LockScreens1920X1280 = $LockScreens | Where-Object { $_.Name -like "LockScreen_*$res1920X1280.jpg" }
            $LockScreen = get-random -InputObject $LockScreens1920X1280.FullName
            Set-ItemProperty -Path $strPath -Name LockScreenImage -value "$ImagePath$LockScreen"
            LogWrite("LockScreen = $LockScreen")
        }
        "2048X1152" {
            $LockScreens2048X1152 = $LockScreens | Where-Object { $_.Name -like "LockScreen_*$res2048X1152.jpg" }
            $LockScreen = get-random -InputObject $LockScreens2048X1152.FullName
            Set-ItemProperty -Path $strPath -Name LockScreenImage -value $LockScreen
            LogWrite("LockScreen = $LockScreen")
        }
        "2560X1440" {
            $LockScreens2560X1440 = $LockScreens | Where-Object { $_.Name -like "LockScreen_*$res2560X1440.jpg" }
            $LockScreen = get-random -InputObject $LockScreens2560X1440.FullName
            Set-ItemProperty -Path $strPath -Name LockScreenImage -value $LockScreen
            LogWrite("LockScreen = $LockScreen")
        }
        "2560X1600" {
            $LockScreens2560X1600 = $LockScreens | Where-Object { $_.Name -like "LockScreen_*$res2560X1600.jpg" }
            $LockScreen = get-random -InputObject $LockScreens2560X1600.FullName
            Set-ItemProperty -Path $strPath -Name LockScreenImage -value $LockScreen
            LogWrite("LockScreen = $LockScreen")
        }
        "3840X1600" {
            $LockScreens3840X1600 = $LockScreens | Where-Object { $_.Name -like "LockScreen_*$res3840X1600.jpg" }
            $LockScreen = get-random -InputObject $LockScreens3840X1600.FullName
            Set-ItemProperty -Path $strPath -Name LockScreenImage -value $LockScreen
            LogWrite("LockScreen = $LockScreen")
        }
        "3072X1728" {
            $LockScreens3072X1728 = $LockScreens | Where-Object { $_.Name -like "LockScreen_*$res3072X1728.jpg" }
            $LockScreen = get-random -InputObject $LockScreens3072X1728.FullName
            Set-ItemProperty -Path $strPath -Name LockScreenImage -value $LockScreen
            LogWrite("LockScreen = $LockScreen")
        }
        "3840X2160" {
            $LockScreens3840X2160 = $LockScreens | Where-Object { $_.Name -like "LockScreen_*$res3840X2160.jpg" }
            $LockScreen = get-random -InputObject $LockScreens3840X2160.FullName
            Set-ItemProperty -Path $strPath -Name LockScreenImage -value $LockScreen
            LogWrite("LockScreen = $LockScreen")
        }
        default {
            $LockScreens1920X1080 = $LockScreens | Where-Object { $_.Name -like "LockScreen_*$res1920X1080.jpg" }
            $LockScreen = get-random -InputObject $LockScreens1920X1080.FullName
            Set-ItemProperty -Path $strPath -Name LockScreenImage -value $LockScreen
            LogWrite("LockScreen Default = $LockScreen")
        }
    }
}
End {
    LogWrite("Script execution complete")
}
