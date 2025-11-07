# ============================================================================
# Windows Fresh Setup Script - Winget Edition
# ============================================================================

Write-Host "`n=== Windows Setup Script ===" -ForegroundColor Cyan
Write-Host "Setting up your Windows environment...`n" -ForegroundColor White

# ============================================================================
# Install packages from winget baseline
# ============================================================================
Write-Host "`n=== Installing Winget Packages ===" -ForegroundColor Cyan

$baselineJson = Join-Path $PSScriptRoot "baseline.json"

if (Test-Path $baselineJson) {
    Write-Host "Found baseline.json, importing packages..." -ForegroundColor Green
    winget import -i $baselineJson --accept-package-agreements --accept-source-agreements
} else {
    Write-Host "WARNING: baseline.json not found at $baselineJson" -ForegroundColor Yellow
    Write-Host "Skipping winget package installation..." -ForegroundColor Yellow
    Write-Host "Please ensure baseline.json is in the same directory as this script.`n" -ForegroundColor Yellow
}

# Install additional packages not in baseline (if needed)
Write-Host "`nInstalling PowerToys and PowerShell Preview..." -ForegroundColor Yellow

# ============================================================================
# Install WSL
# ============================================================================
Write-Host "`n=== Installing WSL ===" -ForegroundColor Cyan
wsl --install

# ============================================================================
# Import WSL Distributions from External Drives
# ============================================================================
Write-Host "`n=== Importing WSL Distributions ===" -ForegroundColor Cyan

# Prompt for Ubuntu import
$importUbuntu = Read-Host "Do you want to import Ubuntu from an external drive? (Y/N)"
if ($importUbuntu -eq "Y" -or $importUbuntu -eq "y") {
    $ubuntuTarPath = Read-Host "Enter the full path to the Ubuntu .tar file (e.g., D:\ubuntu.tar)"
    if (Test-Path $ubuntuTarPath) {
        $ubuntuInstallPath = Read-Host "Enter installation path for Ubuntu (e.g., C:\WSL\Ubuntu)"
        Write-Host "Importing Ubuntu..." -ForegroundColor Yellow
        wsl --import Ubuntu $ubuntuInstallPath $ubuntuTarPath
        Write-Host "Ubuntu imported successfully" -ForegroundColor Green
    } else {
        Write-Host "Ubuntu tar file not found at: $ubuntuTarPath" -ForegroundColor Red
    }
}

# Prompt for Kali import
$importKali = Read-Host "Do you want to import Kali from an external drive? (Y/N)"
if ($importKali -eq "Y" -or $importKali -eq "y") {
    $kaliTarPath = Read-Host "Enter the full path to the Kali .tar file (e.g., D:\kali.tar)"
    if (Test-Path $kaliTarPath) {
        $kaliInstallPath = Read-Host "Enter installation path for Kali (e.g., C:\WSL\Kali)"
        Write-Host "Importing Kali..." -ForegroundColor Yellow
        wsl --import Kali $kaliInstallPath $kaliTarPath
        Write-Host "Kali imported successfully" -ForegroundColor Green
    } else {
        Write-Host "Kali tar file not found at: $kaliTarPath" -ForegroundColor Red
    }
}

Write-Host "`nWSL distributions setup complete" -ForegroundColor Cyan
Write-Host "You can verify with: wsl --list --verbose`n" -ForegroundColor Gray

# ============================================================================
# Install Windows RSAT Tools
# ============================================================================
Write-Host "`n=== Installing AD Tools ===" -ForegroundColor Cyan
Get-WindowsCapability -Name Rsat.ActiveDirectory.DS-LDS.Tools -Online | Add-WindowsCapability -Online

# ============================================================================
# Registry Tweaks
# ============================================================================
Write-Host "`n=== Applying Registry Tweaks ===" -ForegroundColor Cyan

# Enable Legacy Right Click Context Menu
Write-Host "Enabling legacy context menu..." -ForegroundColor Yellow
New-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" -Name "InprocServer32" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Name "(Default)" -Value "" -Force

# Enable NumLock on boot
Write-Host "Enabling NumLock on boot..." -ForegroundColor Yellow
New-PSDrive HKU Registry HKEY_USERS -ErrorAction SilentlyContinue | Out-Null
Set-ItemProperty -Path "HKU:\.Default\Control Panel\Keyboard" -Name "InitialKeyboardIndicators" -Value 2

# Disable task bar grouping
Write-Host "Disabling taskbar grouping..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "EnableTaskGroups" -Value 0

# Left Align Taskbar
Write-Host "Aligning taskbar to the left..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSecondsInSystemClock" -Value 1

# Disable Task View from Taskbar
Write-Host "Disabling task view from taskbar..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value 0

# Disable Searchbox from Taskbar
Write-Host "Disabling searchbox from taskbar..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 0

# Enable seconds in taskbar
Write-Host "Enabling seconds in taskbar..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSecondsInSystemClock" -Value 1

# Setup additional clock for UTC
Write-Host "Setting up UTC clock..." -ForegroundColor Yellow
$clock1 = "HKCU:\Control Panel\TimeDate\AdditionalClocks\1"
if (!(Test-Path $clock1)) {
    New-Item -Path $clock1 -Force | Out-Null
}
Set-ItemProperty -Path $clock1 -Name "DisplayName" -Value "UTC"
Set-ItemProperty -Path $clock1 -Name "Enable" -Value 1
Set-ItemProperty -Path $clock1 -Name "TzRegKeyName" -Value "UTC"

# Setup additional clock for Central Time
Write-Host "Setting up Central Time clock..." -ForegroundColor Yellow
$clock2 = "HKCU:\Control Panel\TimeDate\AdditionalClocks\2"
if (!(Test-Path $clock2)) {
    New-Item -Path $clock2 -Force | Out-Null
}
Set-ItemProperty -Path $clock2 -Name "DisplayName" -Value "Central"
Set-ItemProperty -Path $clock2 -Name "Enable" -Value 1
Set-ItemProperty -Path $clock2 -Name "TzRegKeyName" -Value "Central Standard Time"

# ============================================================================
# Power Configuration
# ============================================================================
Write-Host "`n=== Configuring Power Settings ===" -ForegroundColor Cyan

# Disable hibernation
Write-Host "Disabling hibernation..." -ForegroundColor Yellow
powercfg.exe /hibernate off

# Force P Cores on VMware (if VMware is installed)
$vmwarePath = "C:\Program Files (x86)\VMware\VMware Workstation\x64\vmware-vmx.exe"
if (Test-Path $vmwarePath) {
    Write-Host "Configuring VMware power settings..." -ForegroundColor Yellow
    powercfg /powerthrottling disable /path $vmwarePath
} else {
    Write-Host "VMware not found, skipping power throttling config..." -ForegroundColor Gray
}

# ============================================================================
# Create Symlinks for Config Files
# ============================================================================
Write-Host "`n=== Creating Config Symlinks ===" -ForegroundColor Cyan

$dotconfigPath = Join-Path $PSScriptRoot "..\dotconfig"

if (Test-Path $dotconfigPath) {
    # Git config symlinks
    Write-Host "Creating Git config symlinks..." -ForegroundColor Yellow
    New-Item -Path ~\.gitconfig -ItemType SymbolicLink -Value "$dotconfigPath\git\.gitconfig" -Force -ErrorAction SilentlyContinue
    New-Item -Path ~\.gitconfig-windows -ItemType SymbolicLink -Value "$dotconfigPath\git\.gitconfig-windows" -Force -ErrorAction SilentlyContinue
    New-Item -Path ~\.gitignore -ItemType SymbolicLink -Value "$dotconfigPath\git\.gitignore" -Force -ErrorAction SilentlyContinue

    # Windows Terminal settings symlink
    Write-Host "Creating Windows Terminal settings symlink..." -ForegroundColor Yellow
    $wtSettingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    New-Item -Path $wtSettingsPath -ItemType SymbolicLink -Value "$dotconfigPath\Win_Terminal\settings.json" -Force -ErrorAction SilentlyContinue
} else {
    Write-Host "WARNING: dotconfig folder not found at $dotconfigPath" -ForegroundColor Yellow
    Write-Host "Skipping symlink creation..." -ForegroundColor Yellow
}

# ============================================================================
# Create CSOC_Investigations Folder with Custom Permissions
# ============================================================================
Write-Host "`n=== Creating CSOC_Investigations Folder ===" -ForegroundColor Cyan

$folderPath = "C:\CSOC_Investigations"
if (!(Test-Path $folderPath)) {
    Write-Host "Creating folder at $folderPath..." -ForegroundColor Yellow
    New-Item -Path $folderPath -ItemType Directory -Force | Out-Null
}

# Get current ACL and disable inheritance
Write-Host "Configuring folder permissions..." -ForegroundColor Yellow
$acl = Get-Acl $folderPath
$acl.SetAccessRuleProtection($true, $false)  # Disable inheritance, don't preserve existing

# Clear existing access rules
$acl.Access | ForEach-Object { $acl.RemoveAccessRule($_) | Out-Null }

# Define the groups
$groups = @("Administrators", "Authenticated Users", "Users")

foreach ($group in $groups) {
    # Read/Write for files only (Object Inherit, No Propagate)
    $fileRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
        $group,
        "Read,Write,Delete",
        "ObjectInherit",
        "InheritOnly",
        "Allow"
    )
    $acl.AddAccessRule($fileRule)

    # Full control for folders and subfolders (Container Inherit only)
    $folderRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
        $group,
        "FullControl",
        "ContainerInherit",
        "None",
        "Allow"
    )
    $acl.AddAccessRule($folderRule)
}

# Apply the ACL
Set-Acl -Path $folderPath -AclObject $acl
Write-Host "ACL configuration applied successfully" -ForegroundColor Green

# ============================================================================
# Windows Terminal Multi-Profile Startup Task
# Creates a scheduled task that launches Windows Terminal with PowerShell,
# Ubuntu, and Kali tabs on login, with PowerShell focused.
# ============================================================================

Write-Host "`n=== Windows Terminal Startup Task Setup ===" -ForegroundColor Cyan
Write-Host "This will create a task to launch Terminal with 3 tabs on login`n" -ForegroundColor White

# Configuration
$taskName = "Windows Terminal Multi-Profile Startup"
$wtExePath = "$env:LOCALAPPDATA\Microsoft\WindowsApps\wt.exe"

# Verify Windows Terminal is installed
Write-Host "Checking for Windows Terminal..." -ForegroundColor Yellow
if (Test-Path $wtExePath) {
    Write-Host "Windows Terminal found at: $wtExePath" -ForegroundColor Green

    # Remove existing task if it exists
    Write-Host "`nChecking for existing task..." -ForegroundColor Yellow
    $existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
    if ($existingTask) {
        Write-Host "Found existing task. Removing..." -ForegroundColor Yellow
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
    }

    # Create the scheduled task
    Write-Host "Creating scheduled task..." -ForegroundColor Yellow

    # Task action with multi-profile arguments
    $arguments = '-p "PowerShell" ; new-tab -p "Ubuntu" ; new-tab -p "Kali"; focus-tab -t 0'
    $action = New-ScheduledTaskAction -Execute $wtExePath -Argument $arguments

    # Task trigger (at logon)
    $trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME

    # Task settings
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit 0

    # Create the task
    $principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -RunLevel Limited
    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Description "Launches Windows Terminal with PowerShell, Ubuntu, and Kali tabs on login"

    Write-Host "Scheduled task created successfully" -ForegroundColor Green
    Write-Host "Windows Terminal will launch with 3 tabs on next login" -ForegroundColor Cyan
} else {
    Write-Host "Windows Terminal not found!" -ForegroundColor Red
    Write-Host "Please install Windows Terminal from the Microsoft Store and try again." -ForegroundColor Yellow
}

# ============================================================================
# Restart Windows Explorer
# ============================================================================
Write-Host "`n=== Restarting Windows Explorer ===" -ForegroundColor Cyan
Stop-Process -Name explorer -Force
Start-Sleep -Seconds 2
Start-Process explorer

Write-Host "`n=== Setup Complete! ===" -ForegroundColor Green
Write-Host "Please restart your computer for all changes to take effect.`n" -ForegroundColor Yellow
