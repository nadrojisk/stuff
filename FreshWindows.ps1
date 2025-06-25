# Installs chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

choco feature enable -n allowGlobalConfirmation

choco install notepadplusplus `
	vscode `
	sharex `
	#googlechrome.dev `
	firefox `
	brave `
	firefox-dev --pre `
	#mobaxterm `
	git.install `
	wireshark `
	burp-suite-free-edition `
	1password `
	adobereader `
	7zip.install `
	discord `
	mattermost-desktop `
	firacode `
	nerd-fonts-Meslo `
	spotify `
	obsidian `
	sqlitestudio `

# Installs WSL
wsl --install

# Installs Get-ADUser and other AD Tools
Get-WindowsCapability -Name Rsat.ActiveDirectory.DS-LDS.Tools -Online | Add-WindowsCapability -Online

# Enabled Legacy Right Click Context Menu
New-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -force

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