# Server fish configuration (linked to ~/.config/fish/conf.d/ by `make install-server`).
# The portable subset of ../config.fish: aliases, zoxide and the prompt, without the WSL and 1Password parts.
if status is-interactive
    set -g fish_greeting
    command -q nvim; and alias vim=nvim
    alias ip="ip --color=auto"
    command -q zoxide; and zoxide init fish | source
    # The prompt. Installed by the homelab Ansible playbook (the apt package on Debian, the release binary on Ubuntu); its Nerd Font
    # symbols preset is generated on the host, not tracked here.
    command -q starship; and starship init fish | source
end

set -gx EDITOR vim
