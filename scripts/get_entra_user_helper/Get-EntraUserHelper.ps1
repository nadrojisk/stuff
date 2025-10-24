<#
.SYNOPSIS
    Get Entra User information with optional GUI display.

.DESCRIPTION
    Queries Microsoft Entra ID for user information and displays specified fields.
    Supports multiple users and can display results in console table or GUI format.
    Automatically connects to Entra if not already connected.

.PARAMETER Users
    One or more usernames to search for. Can be space or comma separated.

.PARAMETER GUI
    Display results in a graphical window instead of console output.

.EXAMPLE
    GEU sosn071
    Get user information for sosn071 in table format.

.EXAMPLE
    GEU sosn071 -GUI
    Get user information for sosn071 in a GUI window.

.EXAMPLE
    GEU sosn071, test, user2
    Get information for multiple users.

.EXAMPLE
    GEU sosn071 test user2 -GUI
    Get information for multiple users in a grid view.

.NOTES
    Author: Generated for PNNL
    Requires: Microsoft.Graph.Entra module
#>
function Get-EntraUserHelper {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromRemainingArguments = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Users,
        
        [Parameter()]
        [switch]$GUI
    )
    
    begin {
        # Define fields to display
        $script:FieldsToShow = @(
            'createdDateTime'
            'companyName'
            'displayName'
            'mail'
            'employeeId'
            'jobTitle'
            'department'
            'city'
            'accountEnabled'
            'mailNickname'
            #'onPremisesSamAccountName'
            #'onPremisesUserPrincipalName'
            'userPrincipalName'
            'onPremisesSecurityIdentifier'
        )
        
        # Ensure Entra connection
        Test-EntraConnection
    }
    
    process {
        # Parse and clean user input
        $userList = Get-CleanedUserList -InputUsers $Users
        
        if ($userList.Count -eq 0) {
            Write-Warning "Please provide at least one username"
            return
        }
        
        # Query all users
        $results = Get-EntraUsers -UserList $userList
        
        if ($results.Count -eq 0) {
            Write-Warning "No users found"
            return
        }
        
        # Display results
        if ($GUI) {
            Show-Results -Results $results -AsGUI
        }
        else {
            Show-Results -Results $results
        }
    }
}

function Test-EntraConnection {
    <#
    .SYNOPSIS
        Ensures an active Entra connection exists.
    #>
    [CmdletBinding()]
    param()
    
    $context = Get-EntraContext -ErrorAction SilentlyContinue
    if ($null -eq $context) {
        Write-Verbose "Connecting to Entra..." -ForegroundColor Yellow
        Connect-Entra -Scopes 'User.ReadWrite.All' -NoWelcome
    }
    else {
        Write-Verbose "Already connected to Entra"
    }
}

function Get-CleanedUserList {
    <#
    .SYNOPSIS
        Parses and cleans user input, handling both space and comma-separated values.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$InputUsers
    )
    
    $cleanedList = @()
    
    foreach ($user in $InputUsers) {
        # Split on commas and trim whitespace
        $cleanedList += $user -split ',' | 
            ForEach-Object { $_.Trim() } | 
            Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    }
    
    return $cleanedList
}

function Get-EntraUsers {
    <#
    .SYNOPSIS
        Queries Entra for specified users.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$UserList
    )
    
    $results = @()
    
    foreach ($user in $UserList) {
        try {
            Write-Verbose "Querying user: $user"
            # Detect if input is a SID (S-1-5-...)
            if ($user -match '^S-1-\d+-\d+(?:-\d+)+$') {
                $result = Get-EntraUser -Filter "onPremisesSecurityIdentifier eq '$user'" -ErrorAction Stop
            }
            else {
                $result = Get-EntraUser -Search $user -ErrorAction Stop
            }
            $results += $result
        }
        catch {
            Write-Warning "Could not find user: $user"
        }
    }
    
    return $results
}

function Show-Results {
    <#
    .SYNOPSIS
        Displays query results in either console or GUI format.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [array]$Results,
        
        [Parameter()]
        [switch]$AsGUI
    )
    
    if ($AsGUI) {
        if ($Results.Count -eq 1) {
            Show-EntraUserDetailGUI -UserObject $Results[0]
        }
        else {
            # Multiple users - show in grid view
            $Results | 
                Select-Object -Property $script:FieldsToShow | 
                Out-GridView -Title "Entra Users ($($Results.Count) found)"
        }
    }
    else {
        # Console table output
        $Results | 
            Select-Object -Property $script:FieldsToShow | 
            Format-Table -Property * -AutoSize
    }
}

function Show-EntraUserDetailGUI {
    <#
    .SYNOPSIS
        Displays detailed user information in a Windows Forms GUI.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object]$UserObject
    )
    
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    
    # Create main form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Entra User Details - $($UserObject.displayName)"
    $form.Size = New-Object System.Drawing.Size(800, 600)
    $form.StartPosition = 'CenterScreen'
    $form.Font = New-Object System.Drawing.Font('Segoe UI', 10)
    $form.MinimumSize = New-Object System.Drawing.Size(600, 400)
    
    # Create scrollable panel
    $panel = New-Object System.Windows.Forms.Panel
    $panel.Location = New-Object System.Drawing.Point(10, 10)
    $panel.Size = New-Object System.Drawing.Size(760, 500)
    $panel.AutoScroll = $true
    $panel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
    $panel.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor 
                    [System.Windows.Forms.AnchorStyles]::Bottom -bor 
                    [System.Windows.Forms.AnchorStyles]::Left -bor 
                    [System.Windows.Forms.AnchorStyles]::Right
    
    # Populate panel with user data
    $yPosition = 10
    
    foreach ($fieldName in $script:FieldsToShow) {
        $value = $UserObject.$fieldName
        
        if ($null -eq $value -or [string]::IsNullOrWhiteSpace($value)) {
            continue
        }
        
        # Create label for field name
        $label = New-Object System.Windows.Forms.Label
        $label.Location = New-Object System.Drawing.Point(10, $yPosition)
        $label.Size = New-Object System.Drawing.Size(250, 25)
        $label.Text = "$($fieldName):"
        $label.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold)
        $label.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor 
                        [System.Windows.Forms.AnchorStyles]::Left
        $panel.Controls.Add($label)
        
        # Create textbox for value
        $textBox = New-Object System.Windows.Forms.TextBox
        $textBox.Location = New-Object System.Drawing.Point(270, $yPosition)
        $textBox.Size = New-Object System.Drawing.Size(460, 25)
        $textBox.Text = $value.ToString()
        $textBox.ReadOnly = $true
        $textBox.BackColor = [System.Drawing.Color]::White
        $textBox.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
        $textBox.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor 
                          [System.Windows.Forms.AnchorStyles]::Left -bor 
                          [System.Windows.Forms.AnchorStyles]::Right
        
        # Enable multiline for long values
        if ($textBox.Text.Length -gt 50) {
            $textBox.Multiline = $true
            $textBox.Height = 60
            $textBox.ScrollBars = 'Vertical'
        }
        
        $panel.Controls.Add($textBox)
        
        # Update position for next field
        $yPosition += $textBox.Height + 10
    }
    
    $form.Controls.Add($panel)
    
    # Create close button
    $closeButton = New-Object System.Windows.Forms.Button
    $closeButton.Location = New-Object System.Drawing.Point(350, 520)
    $closeButton.Size = New-Object System.Drawing.Size(100, 30)
    $closeButton.Text = 'Close'
    $closeButton.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom
    $closeButton.Add_Click({ $form.Close() })
    $form.Controls.Add($closeButton)
    
    # Handle form resize to reposition button
    $form.Add_Resize({
        $closeButton.Location = New-Object System.Drawing.Point(
            ($form.ClientSize.Width / 2 - 50), 
            ($form.ClientSize.Height - 60)
        )
    })
    
    # Show form
    [void]$form.ShowDialog()
}

# Create alias for easier use
Set-Alias -Name GEU -Value Get-EntraUserHelper

