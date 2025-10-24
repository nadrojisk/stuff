<#
	.SYNOPSIS
		Parses Chrome notification subscriptions from the provided file located at the path
		 or at the standard location at the provided hosts
	.EXAMPLE
		Get-ChromeNotifications.ps1 -Path .\Preferences
		Prints off the subscribed notifications found at .\Preferences
	.EXAMPLE
		Get-ChromeNotifications.ps1 -Hosts host1,host2,host3
		Prints off the subscribed notifications found on each host at each users chrome location
		i.e. C:\Users\john\AppData\Local\Google\Chrome\User Data\Defaults\Preferences

#>

param (
	[parameter(ParameterSetName = "seta", Mandatory = $true)][array]$hosts = @(),
	[parameter(ParameterSetName = "setb", Mandatory = $true)][string]$path = ""
)


Function ParseFile($file, $formatting) {
	$preferences = Get-Content $file -Raw -ErrorAction SilentlyContinue 
    if ($preferences){
        $notifications = (ConvertFrom-Json $preferences).profile.content_settings.exceptions.notifications
        if ($notifications){
	        $notifications | Get-member -Membertype NoteProperty |
	        ForEach-Object {
		        # Check if notification is enabled, 2 means disabled
		        if ($_.ToString().contains("setting=1")) {
			        $output = $formatting, "$($_.Name)" -join ''
                    Write-Output $output
		        }
	        }
        }
    }

}

if ($hosts) {
	# Loops through each host and check their notifications
	foreach ($hostname in $hosts) {
		Write-Output $hostname
        # Have to do some funky stuff with Argumnet list to have ParseFile in scope on remote computer
		Invoke-Command -ComputerName $hostname  -ArgumentList ${function:ParseFile}.Ast.Name,${function:ParseFile} -ScriptBlock {
            $null = New-Item -Path function: -Name $args[0] -Value $args[1]
			foreach ($folder in Get-ChildItem -Directory "C:\Users") {
				Write-Output "`t $($folder.Name)"
				$google_user_data = Join-Path "C:\Users\" $folder | Join-Path -ChildPath "\AppData\Local\Google\Chrome\User Data\"
				# Check every user profile: "Profile X" or "Default"
				foreach ($data_folder in Get-ChildItem -ErrorAction Ignore -Directory $google_user_data) {
					if (($data_folder.Name.contains("Profile")) -or ($data_folder.Name.contains("Default"))) {
						Write-Output "`t`t $($data_folder.Name)"
                        $preferences = Join-Path $google_user_data $data_folder | Join-Path -ChildPath "\Preferences"
						ParseFile $preferences "`t`t`t"
					}
				}
			}
		} 
	}
}
else {
	ParseFile $path
}
