# ── PATH ──────────────────────────────────────────────────────────────────────
export PATH=$PATH:$HOME/.local/bin
export PATH=$HOME/Scripts/DidierStevensSuite/:$PATH
export PATH="$PATH:/opt/nvim/"
if command -v go &>/dev/null; then
    export PATH="$PATH:$(go env GOPATH)/bin"
fi
export PATH=$HOME/.opencode/bin:$PATH

# ── OH MY ZSH ─────────────────────────────────────────────────────────────────
export ZSH="$XDG_DATA_HOME/oh-my-zsh"
ZSH_THEME=""
DISABLE_UPDATE_PROMPT=true

plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    history-substring-search
    colored-man-pages
    docker
    kubectl
    node
    npm
    sudo
    web-search
)

zstyle ':omz:update' mode auto
[[ -f $ZSH/oh-my-zsh.sh ]] && source $ZSH/oh-my-zsh.sh
[[ -s "${ZSH_COMPDUMP}" && ! -s "${ZSH_COMPDUMP}.zwc" ]] && zcompile "${ZSH_COMPDUMP}"

# ── PROMPT ────────────────────────────────────────────────────────────────────
if command -v starship &>/dev/null; then
    eval "$(starship init zsh)"
fi

# ── EDITOR / BROWSER ──────────────────────────────────────────────────────────
export EDITOR=vim
[[ -n $WSL_DISTRO_NAME ]] && export BROWSER=wslview

# ── ZSH OPTIONS ───────────────────────────────────────────────────────────────
unsetopt extendedglob

# ── NVM ───────────────────────────────────────────────────────────────────────
# NVM_DIR set in .zshenv ($XDG_DATA_HOME/nvm)
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" --no-use
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# ── PYENV ─────────────────────────────────────────────────────────────────────
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv &>/dev/null; then
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
fi

# ── ALIASES ───────────────────────────────────────────────────────────────────
alias zshconfig="vim ~/.zshrc"
alias ohmyzsh="vim ~/.oh-my-zsh"
alias zshsource="source ~/.zshrc"
alias ip='ip --color=auto'
alias grep='rg'
alias vim='nvim'

# ── WSL ───────────────────────────────────────────────────────────────────────
if [[ -n $WSL_DISTRO_NAME ]]; then
    alias clip='iconv -f UTF-8 -t UTF-16LE | clip.exe'
fi
