# Mac OS X setup


## Inspired By
https://github.com/alexramirez/mac-setup

Facing the setup of a new machine (or the need to reinstall after a fresh OS install or the like), here's a very brief and basic list of the usual suspects, related to the setup of a mac computer to work with (mostly related to a scripting languages context).

## Homebrew & cask
The package manager is the default first thing I always install. Simply following the default steps. Homebrew downloads and installs the Command Line Tools for Xcode, so we're all good. `brew cask` handles the tapping, so we are cask-enabled too. Finally, `brew-cask-upgrade` provides upgrade-like capabilities to cask, and we're all set.
```bash
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew cask
brew tap buo/cask-upgrade
```
## Mac App Store
If some previously purchased software from the Mac App Store needs to be included, we can use `mas` to ease the installs.

```bash
brew install mas
```

## My curated list of apps (and all that jazz)
Once we have `homebrew`, `cask` (and `mas` if needed) we're ready to go (yes, these lists might be scripted, this is just a curated set):

### Productivity

```bash
# Efficiency booster
brew cask install alfred

# Time warrior
brew install timewarrior

# Slack
brew cask install slack

# Wunderlist
mas install 410628904

# Amphetamine
mas install 937984704

# Magnet
mas install 441258766
```
### Browsers

```bash
# Browsers
brew cask install firefox
```

### Common apps

```bash

# Authy
brew cask install authy

# Dropbox
brew cask install dropbox

# Some of the Google stuff
brew cask install google-photos-backup-and-sync

# MS
brew cask install microsoft-office

# Spotify
brew cask install spotify

# The Unarchiver
brew cask install the-unarchiver

# VLC
brew cask install vlc

```

### Development

```bash
# A good terminal
brew install tree
brew install wget
brew cask install iterm2
brew install jq
brew install zsh zsh-completions zsh-syntax-highlighting zsh-autosuggestions
# https://github.com/robbyrussell/oh-my-zsh
brew install thefuck

# Text editors/IDEs
brew cask install visual-studio-code


# Docker
brew cask install docker

# Gas Mask
brew cask install gas-mask

# Git-related
brew cask install rowanj-gitx
brew cask install sourcetree
brew cask instal kdiff3

# GoLang
brew install go

# Python
brew install python3

# Xcode. Will take forever to download, yes. Not needed by everyone.
mas install 497799835
```
