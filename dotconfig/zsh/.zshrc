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

# 1Password credential cache — TTL in seconds (1 hour)
_OP_CACHE_TTL=3600

_get_op_secret() {
    local cache_var="$1" ts_var="$2" op_path="$3"
    local cached_val cached_ts now age

    # Check cache: must exist, be non-empty, and within TTL
    cached_val="${!cache_var}"
    if [[ -n "$cached_val" ]]; then
        cached_ts="${!ts_var}"
        if [[ -n "$cached_ts" ]]; then
            now=$(date +%s)
            age=$(( now - cached_ts ))
            if (( age < _OP_CACHE_TTL )); then
                echo "$cached_val"
                return 0
            fi
        fi
    fi

    local secret
    secret=$(op.exe read "$op_path" 2>/dev/null)
    if [[ -z "$secret" ]]; then
        echo "error: failed to retrieve $op_path from 1Password" >&2
        return 1
    fi
    printf -v "$cache_var" '%s' "$secret"
    printf -v "$ts_var" '%s' "$(date +%s)"
    echo "$secret"
}

function claude() {
    local key
    key=$(_get_op_secret _INCUBATOR_KEY_CACHE _INCUBATOR_KEY_TS "op://PNNL/Incubator CSOC Devwork/credential") || return 1
    ANTHROPIC_FOUNDRY_API_KEY="$key" command claude "$@"
}

function opencode() {
    local key jira confluence
    key=$(_get_op_secret _INCUBATOR_KEY_CACHE _INCUBATOR_KEY_TS "op://PNNL/Incubator CSOC Devwork/credential") || return 1
    jira=$(_get_op_secret _JIRA_PAT_CACHE _JIRA_PAT_TS "op://PNNL/Jira PAT/credential") || return 1
    confluence=$(_get_op_secret _CONFLUENCE_PAT_CACHE _CONFLUENCE_PAT_TS "op://PNNL/Confluence PAT/credential") || return 1
    PNNL_INCUBATOR_API_KEY="$key" \
        JIRA_PERSONAL_TOKEN="$jira" \
        CONFLUENCE_PERSONAL_TOKEN="$confluence" \
        command opencode "$@"
}

function az-login() {
    local user cred tenant
    user=$(_get_op_secret _AZ_USERNAME_CACHE _AZ_USERNAME_TS "op://PNNL/Asgard Azure Service Principal/username") || return 1
    cred=$(_get_op_secret _AZ_CREDENTIAL_CACHE _AZ_CREDENTIAL_TS "op://PNNL/Asgard Azure Service Principal/credential") || return 1
    tenant=$(_get_op_secret _AZ_TENANT_CACHE _AZ_TENANT_TS "op://PNNL/Asgard Azure Service Principal/tenant_id") || return 1
    AZURE_CLIENT_SECRET="$cred" az login --service-principal \
        -u "$user" \
        --tenant "$tenant"
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
