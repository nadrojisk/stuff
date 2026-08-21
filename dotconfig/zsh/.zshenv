
# Added by jcode installer
export PATH="/home/sosn071/.local/bin:$PATH"

# ── XDG Base Directories ──────────────────────────────────────────────────────
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

# ── History ───────────────────────────────────────────────────────────────────
export HISTFILE="$XDG_STATE_HOME/zsh/history"
export LESSHISTFILE="$XDG_STATE_HOME/less/history"
export PSQL_HISTORY="$XDG_STATE_HOME/psql/history"

# ── ZSH ───────────────────────────────────────────────────────────────────────
export ZSH_COMPDUMP="$XDG_CACHE_HOME/zsh/zcompdump"

# ── Dev tools ─────────────────────────────────────────────────────────────────
export NVM_DIR="$XDG_DATA_HOME/nvm"
export IPYTHONDIR="$XDG_CONFIG_HOME/ipython"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"

# ── Cloud / Infra ─────────────────────────────────────────────────────────────
export AWS_CONFIG_FILE="$XDG_CONFIG_HOME/aws/config"
export AWS_SHARED_CREDENTIALS_FILE="$XDG_CONFIG_HOME/aws/credentials"
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"
export TF_CLI_CONFIG_FILE="$XDG_CONFIG_HOME/terraform/terraformrc"
export TF_PLUGIN_CACHE_DIR="$XDG_CACHE_HOME/terraform"
export AZURE_CONFIG_DIR="$XDG_CONFIG_HOME/azure"

# ── GPU / CUDA ────────────────────────────────────────────────────────────────
export CUDA_CACHE_PATH="$XDG_CACHE_HOME/nv"

# ── wget ──────────────────────────────────────────────────────────────────────
export WGETRC="$XDG_CONFIG_HOME/wgetrc"
