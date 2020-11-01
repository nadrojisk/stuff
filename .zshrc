# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc
# .
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=/usr/local/bin:$HOME/bin:$PATH

export PATH='$HOME/Library/Python/3.7/bin':$PATH
export PATH="$PATH:/Applications/010 Editor.app/Contents/CmdLine"

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
#DEFAULT_USER = snow

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"


# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"


# plugins
plugins=(
  git
  zsh-autosuggestions
  z
  colored-man-pages
  encode64
  extract
  history
  rsync
  docker 
  docker-compose
)

source $ZSH/oh-my-zsh.sh

# User configuration


# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi


# ssh



# aliases
#source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
export PATH="/usr/local/sbin:$PATH"
alias ghidra="cd /Applications/Ghidra;./ghidraRun; cd -"
alias vim="/usr/local/bin/vim"
alias cupp="cd ~/Documents/cupp; python3 cupp.py"
alias activate="source ./env/bin/activate"
manopt() {
  local cmd=$1 opt=$2
  [[ $opt == -* ]] || { (( ${#opt} == 1 )) && opt="-$opt" || opt="--$opt"; }
  man "$cmd" | col -b | awk -v opt="$opt" -v RS= '$0 ~ "(^|,)[[:blank:]]+" opt "([[:punct:][:space:]]|$)"'
}

source ~/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
