# ── PATH ──────────────────────────────────────────────────────────────────────
export PATH=$PATH:/home/sosn071/.local/bin
export PATH=$HOME/Scripts/DidierStevensSuite/:$PATH
export PATH="$PATH:/opt/nvim/"
if command -v go &>/dev/null; then
    export PATH="$PATH:$(go env GOPATH)/bin"
fi
export PATH=/home/sosn071/.opencode/bin:$PATH

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
source $ZSH/oh-my-zsh.sh
[[ -s "${ZSH_COMPDUMP}" && ! -s "${ZSH_COMPDUMP}.zwc" ]] && zcompile "${ZSH_COMPDUMP}"

# ── PROMPT ────────────────────────────────────────────────────────────────────
if command -v oh-my-posh &>/dev/null; then
    eval "$(oh-my-posh init zsh --config /mnt/d/OneDrive\ -\ PNNL/Documents/custom.omp.json)"
fi

# ── EDITOR / BROWSER ──────────────────────────────────────────────────────────
export EDITOR=vim
export BROWSER=wslview

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

# ── ANTHROPIC / CLAUDE ────────────────────────────────────────────────────────
export CLAUDE_CODE_USE_FOUNDRY=1
export CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1
export ANTHROPIC_FOUNDRY_BASE_URL="https://ai-incubator-api.pnnl.gov"
export ANTHROPIC_DEFAULT_SONNET_MODEL="claude-sonnet-5-project"
export ANTHROPIC_DEFAULT_HAIKU_MODEL="claude-haiku-4-5-20251001-v1-project"
export ANTHROPIC_DEFAULT_OPUS_MODEL="claude-opus-4-8-project"

# Idempotent WSLENV — strip our entries before re-adding to avoid duplicates on re-source
_wslenv_extras="CLAUDE_CODE_USE_FOUNDRY:CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS:ANTHROPIC_FOUNDRY_BASE_URL:ANTHROPIC_DEFAULT_SONNET_MODEL:ANTHROPIC_DEFAULT_HAIKU_MODEL:ANTHROPIC_DEFAULT_OPUS_MODEL"
_wslenv_base=$(echo "$WSLENV" | tr ':' '\n' | grep -Ev '^(CLAUDE_CODE_USE_FOUNDRY|CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS|ANTHROPIC_.*)$' | tr '\n' ':' | sed 's/:$//')
export WSLENV="${_wslenv_base:+$_wslenv_base:}$_wslenv_extras"
unset _wslenv_extras _wslenv_base

# 1Password credential cache — shared tmpfs file, one unlock per WSL session
_OP_SECRETS_FILE="/tmp/op_secrets_$(id -u)"
_OP_CACHE_TTL=3600

function op-unlock() {
    echo "Unlocking 1Password secrets..." >&2
    local incubator jira confluence az_user az_cred az_tenant thehive
    incubator=$(op.exe read "op://PNNL/Incubator CSOC Devwork/credential" 2>/dev/null)
    jira=$(op.exe read "op://PNNL/Jira PAT/credential" 2>/dev/null)
    confluence=$(op.exe read "op://PNNL/Confluence PAT/credential" 2>/dev/null)
    az_user=$(op.exe read "op://PNNL/Asgard Azure Service Principal/username" 2>/dev/null)
    az_cred=$(op.exe read "op://PNNL/Asgard Azure Service Principal/credential" 2>/dev/null)
    az_tenant=$(op.exe read "op://PNNL/Asgard Azure Service Principal/tenant_id" 2>/dev/null)
    thehive=$(op.exe read "op://PNNL/TheHiveDev/credential" 2>/dev/null)

    if [[ -z "$incubator" ]]; then
        echo "error: failed to retrieve secrets from 1Password" >&2
        return 1
    fi

    printf '%s\n' \
        "OP_INCUBATOR=$incubator" \
        "OP_JIRA=$jira" \
        "OP_CONFLUENCE=$confluence" \
        "OP_AZ_USER=$az_user" \
        "OP_AZ_CRED=$az_cred" \
        "OP_AZ_TENANT=$az_tenant" \
        "OP_THEHIVE=$thehive" \
        > "$_OP_SECRETS_FILE"
    chmod 600 "$_OP_SECRETS_FILE"
    echo "1Password secrets cached." >&2
}

function _op_load() {
    local needs_unlock=0
    if [[ ! -f "$_OP_SECRETS_FILE" ]]; then
        needs_unlock=1
    else
        local age=$(( $(date +%s) - $(stat -c %Y "$_OP_SECRETS_FILE") ))
        (( age > _OP_CACHE_TTL )) && needs_unlock=1
    fi

    if (( needs_unlock )); then
        op-unlock || return 1
    fi

    # Touch the file to extend TTL on each use
    touch "$_OP_SECRETS_FILE"

    while IFS='=' read -r key val; do
        [[ -z "$key" ]] && continue
        printf -v "$key" '%s' "$val"
    done < "$_OP_SECRETS_FILE"
}

function op-lock() {
    rm -f "$_OP_SECRETS_FILE"
    echo "1Password secrets cleared." >&2
}

function claude() {
    _op_load || return 1
    ANTHROPIC_FOUNDRY_API_KEY="$OP_INCUBATOR" command claude "$@"
}

function opencode() {
    _op_load || return 1
    PNNL_INCUBATOR_API_KEY="$OP_INCUBATOR" \
        JIRA_PERSONAL_TOKEN="$OP_JIRA" \
        CONFLUENCE_PERSONAL_TOKEN="$OP_CONFLUENCE" \
        THEHIVEDEV_BEARER_TOKEN="$OP_THEHIVE" \
        command opencode "$@"
}

function az-login() {
    _op_load || return 1
    AZURE_CLIENT_SECRET="$OP_AZ_CRED" az login --service-principal \
        -u "$OP_AZ_USER" \
        --tenant "$OP_AZ_TENANT"
}

# ── ALIASES ───────────────────────────────────────────────────────────────────
alias zshconfig="vim ~/.zshrc"
alias ohmyzsh="vim ~/.oh-my-zsh"
alias zshsource="source ~/.zshrc"
alias ip='ip --color=auto'
alias clip='iconv -f UTF-8 -t UTF-16LE | clip.exe'
alias grep='rg'
alias vim='nvim'

function acr-login() {
    az acr login --name acrcsocasgard --expose-token --output tsv --query accessToken \
        | docker login acrcsocasgard.azurecr.io \
            --username 00000000-0000-0000-0000-000000000000 \
            --password-stdin
}

acr_import() {
    local source="$1"
    if [ -z "$source" ]; then
        echo "Usage: acr_import <registry>/<repo>:<tag>" >&2
        return 1
    fi

    local host="${source%%/*}"
    local image
    if [[ "$host" == *.* || "$host" == *:* ]]; then
        image="${source#*/}"
    else
        image="$source"
    fi

    az acr import --name acrcsoc --source "$source" --image "$image"
}
