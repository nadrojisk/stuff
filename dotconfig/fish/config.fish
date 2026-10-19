if status is-interactive
    # Commands to run in interactive sessions can go here
    set -g fish_greeting
    alias grep="rg"
    alias vim="nvim"
    if command -q xsetroot
        xsetroot -cursor_name left_ptr 2>/dev/null
    end
    if command -q xrdb
        echo "Xcursor.size: 14" | xrdb -merge 2>/dev/null
        echo "Xcursor.theme: Adwaita" | xrdb -merge 2>/dev/null
    end
end

# Added by jcode installer
if not contains "$HOME/.local/bin" $PATH
    set -gx PATH "$HOME/.local/bin" $PATH
end

# ── PATH ──────────────────────────────────────────────────────────────────────
fish_add_path --path --append "$HOME/Scripts/DidierStevensSuite"
fish_add_path --path --append /opt/nvim
if command -q go
    fish_add_path --path --append (go env GOPATH)/bin
end
fish_add_path --path "$HOME/.opencode/bin"

# ── PROMPT ────────────────────────────────────────────────────────────────────
if command -q starship
    starship init fish | source
end

# ── EDITOR / BROWSER ──────────────────────────────────────────────────────────
set -gx EDITOR vim
set -gx BROWSER wslview
set -gx XCURSOR_SIZE 14
set -gx XCURSOR_THEME Adwaita
set -gx QT_QPA_PLATFORMTHEME qt6ct
set -gx QT_STYLE_OVERRIDE fusion

# ── PYENV ─────────────────────────────────────────────────────────────────────
set -gx PYENV_ROOT "$HOME/.pyenv"
fish_add_path --path "$PYENV_ROOT/bin"
if command -q pyenv
    pyenv init - fish | source
    pyenv virtualenv-init - fish | source
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
alias wireshark="LIBGL_ALWAYS_SOFTWARE=1 /usr/bin/wireshark 2>/dev/null"
