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

# ── 1PASSWORD ─────────────────────────────────────────────────────────────────
# Secrets resolved into /tmp/op_secrets_<uid> on first use (see functions/).
# TTL is a sliding window — extended on each call to claude/opencode/az-login.
set -g _OP_SECRETS_FILE /tmp/op_secrets_(id -u)
set -g _OP_CACHE_TTL 3600

# ── ZOXIDE ────────────────────────────────────────────────────────────────────
if command -q zoxide
    zoxide init fish | source
end

# ── ALIASES ───────────────────────────────────────────────────────────────────
alias fishconfig="vim ~/.config/fish/config.fish"
alias fishsource="source ~/.config/fish/config.fish"
alias ip="ip --color=auto"
alias clip="iconv -f UTF-8 -t UTF-16LE | clip.exe"
