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
# TTL in seconds (1 hour). Cached secrets are global (unexported) and expire
# after this interval so rotated credentials are not used indefinitely.
set -g _OP_CACHE_TTL 3600

function _get_op_secret
    # Usage: _get_op_secret <cache_var> <timestamp_var> <op_path>
    # Prints the secret to stdout; returns 1 on failure.
    set -l cache_var $argv[1]
    set -l ts_var $argv[2]
    set -l op_path $argv[3]

    # Check cache validity: variable must exist, be non-empty, and within TTL
    set -l cache_valid 0
    if set -q $cache_var
        set -l cached_val $$cache_var
        if test -n "$cached_val"
            if set -q $ts_var
                set -l cached_ts $$ts_var
                set -l now (date +%s)
                set -l age (math $now - $cached_ts)
                if test $age -lt $_OP_CACHE_TTL
                    set cache_valid 1
                end
            end
        end
    end

    if test $cache_valid -eq 0
        set -l secret (op.exe read $op_path 2>/dev/null)
        if test -z "$secret"
            echo "error: failed to retrieve $op_path from 1Password" >&2
            return 1
        end
        set -g $cache_var $secret
        set -g $ts_var (date +%s)
    end

    echo $$cache_var
end

function claude
    set -l key (_get_op_secret _INCUBATOR_KEY_CACHE _INCUBATOR_KEY_TS "op://PNNL/Incubator CSOC Devwork/credential")
    or return 1
    ANTHROPIC_FOUNDRY_API_KEY="$key" command claude $argv
end

function opencode
    set -l key (_get_op_secret _INCUBATOR_KEY_CACHE _INCUBATOR_KEY_TS "op://PNNL/Incubator CSOC Devwork/credential")
    or return 1
    set -l jira (_get_op_secret _JIRA_PAT_CACHE _JIRA_PAT_TS "op://PNNL/Jira PAT/credential")
    or return 1
    set -l confluence (_get_op_secret _CONFLUENCE_PAT_CACHE _CONFLUENCE_PAT_TS "op://PNNL/Confluence PAT/credential")
    or return 1
    PNNL_INCUBATOR_API_KEY="$key" \
        JIRA_PERSONAL_TOKEN="$jira" \
        CONFLUENCE_PERSONAL_TOKEN="$confluence" \
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
    set -l user (_get_op_secret _AZ_USERNAME_CACHE _AZ_USERNAME_TS "op://PNNL/Asgard Azure Service Principal/username")
    or return 1
    set -l cred (_get_op_secret _AZ_CREDENTIAL_CACHE _AZ_CREDENTIAL_TS "op://PNNL/Asgard Azure Service Principal/credential")
    or return 1
    set -l tenant (_get_op_secret _AZ_TENANT_CACHE _AZ_TENANT_TS "op://PNNL/Asgard Azure Service Principal/tenant_id")
    or return 1
    AZURE_CLIENT_SECRET="$cred" az login --service-principal \
        -u "$user" \
        --tenant "$tenant"
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
