# macOS Setup

## Inspired By
https://github.com/alexramirez/mac-setup

## Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew tap buo/cask-upgrade
```

## Mac App Store

```bash
brew install mas
```

## Apps

### Productivity

```bash
brew install --cask alfred
brew install timewarrior
brew install --cask slack
mas install 937984704  # Amphetamine
mas install 441258766  # Magnet
```

### Browsers

```bash
brew install --cask firefox
```

### Common

```bash
brew install --cask authy
brew install --cask dropbox
brew install --cask google-photos-backup-and-sync
brew install --cask microsoft-office
brew install --cask spotify
brew install --cask the-unarchiver
brew install --cask vlc
```

### Development

```bash
brew install tree wget jq
brew install --cask iterm2
brew install zsh zsh-completions zsh-syntax-highlighting zsh-autosuggestions
brew install --cask visual-studio-code
brew install --cask docker
brew install --cask gas-mask
brew install --cask rowanj-gitx
brew install --cask sourcetree
brew install kdiff3
brew install go
brew install python3
mas install 497799835  # Xcode
```
