# Dotfiles & Scripts

Personal configuration files and utility scripts for development and security operations work.

## Repository Structure

```
.
├── dotconfig/          # Application configuration files
├── scripts/            # Utility scripts and tools
├── setup/              # System setup scripts
└── ghidra_custom.tool  # Custom Ghidra tool configuration
```

## Configuration Files (`dotconfig/`)

Personal configuration files for various development tools and applications.

### Available Configs

| Tool | Description |
|------|-------------|
| `git/` | Git configuration and aliases |
| `nvim/` | Neovim editor configuration |
| `tmux/` | Terminal multiplexer settings |
| `vim/` | Vim editor configuration |
| `vscode/` | VS Code settings, tasks, and launch configs |
| `windows_terminal/` | Windows Terminal appearance and behavior |
| `wireshark/` | Wireshark preferences and filters |
| `zsh/` | Zsh shell configuration |

### Installation

**Linux, macOS and WSL:** `make install` links everything in `LINKS` (existing files are backed up to `<name>.bak.<timestamp>`),
and `make check` shows each link's status. It works out the platform and links only that platform's git settings:

| Platform | Extra link |
|---|---|
| WSL (`/proc/version` mentions Microsoft) | `~/.gitconfig-wsl`: Windows `ssh.exe` and the 1Password signer, Windows-friendly `core` settings |
| macOS | `~/.gitconfig-macos`: the 1Password signer; `~/.ssh/platform.conf`: the 1Password SSH agent socket |
| Linux | `~/.ssh/platform.conf`: the 1Password SSH agent socket (`~/.1password/agent.sock`) |

Override the detection with `make install PLATFORM=linux`. The shell configs check `$WSL_DISTRO_NAME` themselves, so the same
`config.fish`, `.zshrc` and `.bashrc` work everywhere. Put per-machine settings in untracked files that the tracked ones source
last (first for ssh, which keeps the first value it sees): `~/.config/fish/local.fish`, `~/.bashrc.local`, `~/.gitconfig.local`
and `~/.ssh/config.local`.

**Windows (PowerShell):**
```powershell
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.gitconfig-windows" -Target ".\dotconfig\git\.gitconfig-windows"
New-Item -ItemType SymbolicLink -Path "$env:APPDATA\Code\User\settings.json" -Target ".\dotconfig\vscode\settings.json"
```

### Server profile

`make install-server` links the subset a headless server needs, and nothing tied to the WSL desktop (no `.gitconfig` with the
identity and 1Password signing, no rc files with WSL or 1Password aliases, no ssh/vscode/wireshark):

| Linked | From |
|---|---|
| `~/.vimrc`, `~/.tmux.conf`, `~/.config/nvim` | `vim/`, `tmux/`, `nvim/` |
| `~/.config/git/config` (no identity, no signing key), `~/.config/git/aliases`, `~/.config/git/ignore` | `git/server.gitconfig`, `git/aliases.gitconfig`, `git/xdg/ignore` |
| `~/.config/fish/conf.d/10-server.fish` | `fish/conf.d/10-server.fish` |
| `~/.config/starship.toml` (the prompt for every shell) | `starship/starship.toml` |

`make check-server` shows their status and `make list-server` prints the repo files involved. The aliases live in one file
(`git/aliases.gitconfig`) that both the desktop `.gitconfig` and the server config include.

This is what the [homelab](https://github.com/nadrojisk/homelab) repo's Ansible `dotfiles` role runs on a new host, pinned to a
commit of this repo. To change what a server gets, edit `SERVER_LINKS` in the `Makefile`; CI fails if a WSL-specific string
(`WSLENV`, `wslview`, a `.exe`, a `/mnt/<drive>/` path) appears in anything the profile links.

## Scripts (`scripts/`)

Collection of utility scripts for various tasks. Each script directory contains its own README with detailed usage instructions.

### Available Scripts

#### Security & Analysis

| Script | Purpose | Language |
|--------|---------|----------|
| `decode_dot_html_url/` | Deobfuscate URLs from HTML files | Bash |
| `decode_notification_spam_url/` | Extract URLs from notification spam | Python |
| `extract_url_from_html_in_eml/` | Dump URLs from email HTML attachments | Python |

#### System Administration

| Script | Purpose | Language |
|--------|---------|----------|
| `compare_installed_software/` | Compare installed software across systems | Python |
| `update_trinity.sh` | Update Trinity scripts/tools | Bash |

#### Browser Forensics

| Script | Purpose | Language |
|--------|---------|----------|
| `pull_chrome_history/` | Extract Chrome browser history | PowerShell |
| `pull_enabled_notifications/` | Get Chrome notification permissions | PowerShell |

### Usage

Navigate to each script's directory and refer to its README for specific usage instructions:

```bash
cd scripts/decode_notification_spam_url
cat README.md
```

## Setup Scripts (`setup/`)

Automated setup scripts for fresh system installations.

- **`FreshWindows.ps1`** - Windows system setup and configuration
- **`mac-setup.md`** - macOS setup guide and instructions

### Windows Setup

```powershell
# Run as Administrator
Set-ExecutionPolicy Bypass -Scope Process -Force
.\setup\FreshWindows.ps1
```

### macOS Setup

```bash
# Follow the guide
cat setup/mac-setup.md
```

## Prerequisites

Different scripts and configs have different requirements:

### General
- Git
- Text editor (vim, nvim, or VS Code)

### Python Scripts
- Python 3.7+
- See individual script READMEs for specific package requirements

### PowerShell Scripts
- PowerShell 5.1+ (Windows)
- PowerShell Core 7+ (cross-platform)
- Module requirements listed in each script

### Shell Scripts
- Bash 4.0+
- Standard Unix utilities (grep, sed, awk)

## Security Tools

Several scripts are designed for security operations and forensics:

- **URL Analysis**: Deobfuscate and extract URLs from suspicious emails/HTML
- **Browser Forensics**: Extract Chrome history and notification data
- **Network Analysis**: Wireshark configurations for packet analysis

## Related Resources

- [Dotfiles Guide](https://dotfiles.github.io/)
- [PowerShell Gallery](https://www.powershellgallery.com/)
- [GitHub CLI](https://cli.github.com/)

## Troubleshooting

### Scripts Won't Execute

**Windows:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Linux/macOS:**
```bash
chmod +x script_name.sh
```

### Symlink Issues

Ensure you have appropriate permissions. On Windows, you may need Developer Mode enabled or Administrator privileges.

### Module Not Found (PowerShell)

```powershell
Install-Module -Name ModuleName -Scope CurrentUser
```

