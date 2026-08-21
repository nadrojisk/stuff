if status is-interactive
    # Commands to run in interactive sessions can go here
    set -g fish_greeting
    alias grep="rg"
    alias vim="nvim"
end

# Added by jcode installer
if not contains "/home/sosn071/.local/bin" $PATH
    set -gx PATH "/home/sosn071/.local/bin" $PATH
end

# ── PATH ──────────────────────────────────────────────────────────────────────
fish_add_path --path --append "$HOME/Scripts/DidierStevensSuite"
fish_add_path --path --append /opt/nvim
if command -q go
    fish_add_path --path --append (go env GOPATH)/bin
end
fish_add_path --path "$HOME/.opencode/bin"

# ── PROMPT ────────────────────────────────────────────────────────────────────
if command -q oh-my-posh
    oh-my-posh init fish --config '/mnt/d/OneDrive - PNNL/Documents/custom.omp.json' | source
end

# ── EDITOR / BROWSER ──────────────────────────────────────────────────────────
set -gx EDITOR vim
set -gx BROWSER wslview

# ── PYENV ─────────────────────────────────────────────────────────────────────
set -gx PYENV_ROOT "$HOME/.pyenv"
fish_add_path --path "$PYENV_ROOT/bin"
if command -q pyenv
    pyenv init - fish | source
    pyenv virtualenv-init - fish | source
end

# ── ANTHROPIC / CLAUDE ────────────────────────────────────────────────────────
set -gx CLAUDE_CODE_USE_FOUNDRY 1
set -gx CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS 1
set -gx ANTHROPIC_FOUNDRY_BASE_URL "https://ai-incubator-api.pnnl.gov"
set -gx ANTHROPIC_DEFAULT_SONNET_MODEL "claude-sonnet-5-project"
set -gx ANTHROPIC_DEFAULT_HAIKU_MODEL "claude-haiku-4-5-20251001-v1-project"
set -gx ANTHROPIC_DEFAULT_OPUS_MODEL "claude-opus-4-8-project"

# Idempotent WSLENV — rebuild each time to avoid duplicates on fishsource
set -l _wslenv_extras \
    CLAUDE_CODE_USE_FOUNDRY \
    CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS \
    ANTHROPIC_FOUNDRY_BASE_URL \
    ANTHROPIC_DEFAULT_SONNET_MODEL \
    ANTHROPIC_DEFAULT_HAIKU_MODEL \
    ANTHROPIC_DEFAULT_OPUS_MODEL
set -l _wslenv_base (string split ":" "$WSLENV" | string match -rv '^(CLAUDE_CODE_USE_FOUNDRY|CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS|ANTHROPIC_.*)$')
set -gx WSLENV (string join ":" $_wslenv_base $_wslenv_extras)

# ── 1PASSWORD CREDENTIAL CACHE ────────────────────────────────────────────────
# Secrets are resolved once per WSL session into a tmpfs file (RAM-only, gone
# on WSL restart). All terminal tabs share the same file — only one 1Password
# prompt per session regardless of how many tabs are open.
#
# To add a new secret: add one line to op-unlock and one read in the wrapper
# that needs it.

set -g _OP_SECRETS_FILE /tmp/op_secrets_(id -u)
set -g _OP_CACHE_TTL 3600

function op-unlock
    # Resolve all secrets from 1Password into the shared tmpfs cache file.
    # Called automatically on first use, or manually to force a refresh.
    echo "Unlocking 1Password secrets..." >&2

    set -l incubator (op.exe read "op://PNNL/Incubator CSOC Devwork/credential" 2>/dev/null)
    set -l jira      (op.exe read "op://PNNL/Jira PAT/credential" 2>/dev/null)
    set -l confluence (op.exe read "op://PNNL/Confluence PAT/credential" 2>/dev/null)
    set -l az_user   (op.exe read "op://PNNL/Asgard Azure Service Principal/username" 2>/dev/null)
    set -l az_cred   (op.exe read "op://PNNL/Asgard Azure Service Principal/credential" 2>/dev/null)
    set -l az_tenant (op.exe read "op://PNNL/Asgard Azure Service Principal/tenant_id" 2>/dev/null)
    set -l thehive   (op.exe read "op://PNNL/TheHiveDev/credential" 2>/dev/null)

    if test -z "$incubator"
        echo "error: failed to retrieve secrets from 1Password" >&2
        return 1
    end

    # Write env-file (mode 600, tmpfs — RAM only)
    printf '%s\n' \
        "OP_INCUBATOR=$incubator" \
        "OP_JIRA=$jira" \
        "OP_CONFLUENCE=$confluence" \
        "OP_AZ_USER=$az_user" \
        "OP_AZ_CRED=$az_cred" \
        "OP_AZ_TENANT=$az_tenant" \
        "OP_THEHIVE=$thehive" \
        > $_OP_SECRETS_FILE
    chmod 600 $_OP_SECRETS_FILE

    echo "1Password secrets cached." >&2
end

function _op_load
    # Load secrets from the cache file into unexported fish globals.
    # Auto-triggers op-unlock if the file is missing or older than TTL.
    set -l needs_unlock 0

    if not test -f $_OP_SECRETS_FILE
        set needs_unlock 1
    else
        set -l age (math (date +%s) - (stat -c %Y $_OP_SECRETS_FILE))
        if test $age -gt $_OP_CACHE_TTL
            set needs_unlock 1
        end
    end

    if test $needs_unlock -eq 1
        op-unlock; or return 1
    end

    # Parse env-file into unexported fish globals
    while read -l line
        set -l key (string split -m1 "=" $line)[1]
        set -l val (string split -m1 "=" $line)[2]
        set -g $key $val
    end < $_OP_SECRETS_FILE
end

function op-lock
    # Wipe the cache file manually (e.g. when stepping away).
    if test -f $_OP_SECRETS_FILE
        rm -f $_OP_SECRETS_FILE
        echo "1Password secrets cleared." >&2
    end
end

function claude
    _op_load; or return 1
    ANTHROPIC_FOUNDRY_API_KEY="$OP_INCUBATOR" command claude $argv
end

function opencode
    _op_load; or return 1
    PNNL_INCUBATOR_API_KEY="$OP_INCUBATOR" \
        JIRA_PERSONAL_TOKEN="$OP_JIRA" \
        CONFLUENCE_PERSONAL_TOKEN="$OP_CONFLUENCE" \
        THEHIVEDEV_BEARER_TOKEN="$OP_THEHIVE" \
        command opencode $argv
end

# ── ZOXIDE ────────────────────────────────────────────────────────────────────
if command -q zoxide
    zoxide init fish | source
end

# ── ALIASES ───────────────────────────────────────────────────────────────────
alias fishconfig="vim ~/.config/fish/config.fish"
alias fishsource="source ~/.config/fish/config.fish"
alias ip="ip --color=auto"
alias clip="iconv -f UTF-8 -t UTF-16LE | clip.exe"

function acr-login
    az acr login --name acrcsocasgard --expose-token --output tsv --query accessToken \
        | docker login acrcsocasgard.azurecr.io \
            --username 00000000-0000-0000-0000-000000000000 \
            --password-stdin
end

function az-login
    _op_load; or return 1
    AZURE_CLIENT_SECRET="$OP_AZ_CRED" az login --service-principal \
        -u "$OP_AZ_USER" \
        --tenant "$OP_AZ_TENANT"
end

function acr_import
    set source $argv[1]
    if test -z "$source"
        echo "Usage: acr_import <registry>/<repo>:<tag>" >&2
        return 1
    end

    set host (string split -m1 "/" $source)[1]
    if string match -q "*/*" $source; and begin
            string match -q "*.*" $host; or string match -q "*:*" $host
        end
        set image (string sub -s (math (string length $host) + 2) $source)
    else
        set image $source
    end

    az acr import --name acrcsoc --source "$source" --image "$image"
end
