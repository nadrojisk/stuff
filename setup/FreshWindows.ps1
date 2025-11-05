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

Get-WindowsCapability -Name Rsat.ActiveDirectory.DS-LDS.Tools -Online | Add-WindowsCapability -Online

# Enabled Legacy Right Click Context Menu
New-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" -Name "InprocServer32" -Force
Set-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Name "(Default)" -Value "" -Force

# Modify Registry to have numkey enabled on boot
New-PSDrive HKU Registry HKEY_USERS
Set-ItemProperty -Path "HKU:\.Default\Control Panel\Keyboard" -Name "InitialKeyboardIndicators" -Value 2

# Disable hibernation
powercfg.exe /hibernate off

# Force P Cores on VMware
powercfg /powerthrottling disable /path "C:\Program Files (x86)\VMware\VMware Workstation\x64\vmware-vmx.exe"

# Disable task bar grouping
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "EnableTaskGroups" -Value 0

# Enable seconds in taskbar
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSecondsInSystemClock" -Value 1

# Setup additional clock for UTC
$clock1 = "HKCU:\Control Panel\TimeDate\AdditionalClocks\1"
if (!(Test-Path $clock1)) {
    New-Item -Path $clock1
}
Set-ItemProperty -Path $clock1 -Name "DisplayName" -Value "UTC"
Set-ItemProperty -Path $clock1 -Name "Enable" -Value 1
Set-ItemProperty -Path $clock1 -Name "TzRegKeyName" -Value "UTC"

# Setup additional clock for Central Time
$clock2 = "HKCU:\Control Panel\TimeDate\AdditionalClocks\2"
if (!(Test-Path $clock2)) {
    New-Item -Path $clock2
}
Set-ItemProperty -Path $clock2 -Name "DisplayName" -Value "Central"
Set-ItemProperty -Path $clock2 -Name "Enable" -Value 1
Set-ItemProperty -Path $clock2 -Name "TzRegKeyName" -Value "Central Standard Time"

# Install WinGet Packages
winget install Microsoft.PowerToys `
	Microsoft.PowerShell.Preview

# Add Gitconfig and Gitignore symlinks
New-Item -Path ~\.gitconfig -ItemType SymbolicLink -Value $PSScriptRoot\..\dotconfig\git\.gitconfig
New-Item -Path ~\.gitconfig-windows -ItemType SymbolicLink -Value $PSScriptRoot\..\dotconfig\git\.gitconfig-windows
New-Item -Path ~\.gitignore -ItemType SymbolicLink -Value $PSScriptRoot\..\dotconfig\git\.gitignore
New-Item -Path ~\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json  -ItemType SymbolicLink -Value $PSScriptRoot\..\dotconfig\Win_Terminal\settings.json

$folderPath = "C:\CSOC_Investigations"
mkdir $folderPath
# Get current ACL and disable inheritance
$acl = Get-Acl $folderPath
$acl.SetAccessRuleProtection($true, $false)  # Disable inheritance, don't preserve existing

# Clear existing access rules
$acl.Access | ForEach-Object { $acl.RemoveAccessRule($_) }

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
# Restart Windows Explorer
Stop-Process -Name explorer -Force
Start-Process explorer