# Server fish configuration (linked to ~/.config/fish/conf.d/ by `make install-server`).
# The portable subset of ../config.fish: aliases, zoxide and the prompt, without the WSL, Foundry, 1Password and work-path parts.
if status is-interactive
    set -g fish_greeting
    command -q nvim; and alias vim=nvim
    alias ip="ip --color=auto"
    command -q zoxide; and zoxide init fish | source
    # oh-my-posh is not in Debian's repositories; install it by hand if you want the prompt (the theme is linked either way).
    if command -q oh-my-posh; and test -r $HOME/.config/oh-my-posh/custom.omp.json
        oh-my-posh init fish --config $HOME/.config/oh-my-posh/custom.omp.json | source
    end
end

set -gx EDITOR vim
