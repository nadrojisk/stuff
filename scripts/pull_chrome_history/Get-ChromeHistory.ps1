<#
.SYNOPSIS
	Pulls Chrome history from a remote computer by checking each user and their profiles.
.DESCRIPTION
	This script retrieves Chrome history from a remote computer by iterating through each user and checking all the profiles associated with each user. It copies the history files to a local destination folder.
.PARAMETER Hosts
	Specifies the remote hosts from which to pull Chrome history. Provide one or more host names.
.EXAMPLE
	Get-ChromeHistory.ps1 -Hosts host1,host2,host3
	Prints the subscribed notifications found on each host at each user's Chrome location.
	For example, C:\Users\john\AppData\Local\Google\Chrome\User Data\Default\History
#>

param (
    [parameter(Mandatory = $true)]
    [array]$Hosts
)

# Loops through each host and checks their notifications
foreach ($hostname in $Hosts) {
    Write-Output $hostname

    # Run the script block on the remote computer to collect history files
    $historyFiles = Invoke-Command -ComputerName $hostname -ScriptBlock {
        $historyFiles = @()

        # Iterate through each user folder on the remote computer
        Get-ChildItem -Path "C:\Users" -Directory | ForEach-Object {
            $google_user_data = Join-Path $_.FullName "AppData\Local\Google\Chrome\User Data\"
            $username = $_
            # Iterate through each profile folder under the user folder
            Get-ChildItem -Path $google_user_data -ErrorAction Ignore -Directory | ForEach-Object {
                if ($_.Name -like "Profile*" -or $_.Name -eq "Default") {
                    # Collect the history file path for the profile
                    $historyPath = Join-Path $_.FullName "History"
                    $historyFiles +=  "$historyPath|$_|$username"
                }
            }
        }

        $historyFiles
    }

    # Copy each history file to the local destination folder
    foreach ($historyFile in $historyFiles) {
        $path, $profile, $username = $historyFile.split("|")
        
        $path = "\\$hostname\$($path.Replace(':', '$'))" 
        $filename = "{0}_{1}_{2}" -f $hostname, $username, $profile
        $destinationPath= "C:\Users\$env:Username\Documents\$filename.sqlite"

        Write-Output "`tCopied $path from $hostname to $destinationPath" 
        Copy-Item -Path $path -Destination $destinationPath -ErrorAction Ignore
    }
}
