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

# Installs Get-ADUser and other AD Tools
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
Write-Host "ACL configuration applied successfully"


# Restart Windows Explorer
Stop-Process -Name explorer -Force
Start-Process explorer