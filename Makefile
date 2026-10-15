REPO  := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
DOT   := $(REPO)/dotconfig
HOME  := $(HOME)

# ── symlink targets ───────────────────────────────────────────────────────────
# Each entry is: <dst>|<src>
LINKS := \
	$(HOME)/.gitconfig|$(DOT)/git/.gitconfig \
	$(HOME)/.gitconfig-wsl|$(DOT)/git/.gitconfig-wsl \
	$(HOME)/.config/git/ignore|$(DOT)/git/xdg/ignore \
	$(HOME)/.config/git/aliases|$(DOT)/git/aliases.gitconfig \
	$(HOME)/.bashrc|$(DOT)/bash/.bashrc \
	$(HOME)/.config/fish/config.fish|$(DOT)/fish/config.fish \
	$(HOME)/.config/fish/functions|$(DOT)/fish/functions \
	$(HOME)/.zshrc|$(DOT)/zsh/.zshrc \
	$(HOME)/.zprofile|$(DOT)/zsh/.zprofile \
	$(HOME)/.zshenv|$(DOT)/zsh/.zshenv \
	$(HOME)/.vimrc|$(DOT)/vim/.vimrc \
	$(HOME)/.config/nvim|$(DOT)/nvim \
	$(HOME)/.tmux.conf|$(DOT)/tmux/.tmux.conf \
	$(HOME)/.ssh/config|$(DOT)/ssh/config \
	$(HOME)/.ssh/allowed_signers|$(DOT)/ssh/allowed_signers \
	$(HOME)/.config/opencode|$(DOT)/opencode \
	$(HOME)/.config/glab-cli/aliases.yml|$(DOT)/glab-cli/aliases.yml \
	$(HOME)/.config/timewarrior/timewarrior.cfg|$(DOT)/timewarrior/timewarrior.cfg \
	$(HOME)/.config/wireshark/preferences|$(DOT)/wireshark/preferences \
	$(HOME)/.config/wireshark/dfilter_buttons|$(DOT)/wireshark/dfilter_buttons \
	$(HOME)/.config/wireshark/decode_as_entries|$(DOT)/wireshark/decode_as_entries

# ── server profile ────────────────────────────────────────────────────────────
# What a headless server needs, and nothing tied to the work laptop: no .gitconfig (work email, signing key, a /home/sosn071
# path), no bash/zsh/fish rc files (hardcoded home, WSL, internal Foundry URL, 1Password helpers), no ssh/glab/vscode/wireshark.
# Used by the homelab repo's Ansible `dotfiles` role (`make install-server`), so the file list lives here only.
SERVER_LINKS := \
	$(HOME)/.vimrc|$(DOT)/vim/.vimrc \
	$(HOME)/.tmux.conf|$(DOT)/tmux/.tmux.conf \
	$(HOME)/.config/nvim|$(DOT)/nvim \
	$(HOME)/.config/git/ignore|$(DOT)/git/xdg/ignore \
	$(HOME)/.config/git/aliases|$(DOT)/git/aliases.gitconfig \
	$(HOME)/.config/git/config|$(DOT)/git/server.gitconfig \
	$(HOME)/.config/fish/conf.d/10-server.fish|$(DOT)/fish/conf.d/10-server.fish

# $(call link_all,<LIST>) / $(call check_all,<LIST>): run _link / _check for every <dst>|<src> pair in LIST.
define link_all
	@$(foreach pair,$(1), \
		$(eval dst := $(word 1,$(subst |, ,$(pair)))) \
		$(eval src := $(word 2,$(subst |, ,$(pair)))) \
		$(MAKE) --no-print-directory _link DST=$(dst) SRC=$(src) ;)
endef

define check_all
	@$(foreach pair,$(1), \
		$(eval dst := $(word 1,$(subst |, ,$(pair)))) \
		$(eval src := $(word 2,$(subst |, ,$(pair)))) \
		$(MAKE) --no-print-directory _check DST=$(dst) SRC=$(src) ;)
endef

.PHONY: install check dirs help install-server check-server list-server

# ── dirs ──────────────────────────────────────────────────────────────────────
# Create XDG state/cache dirs that tools expect to exist but won't create themselves.
dirs: ## Create required XDG state and cache directories
	@mkdir -p \
		$(HOME)/.local/state/zsh \
		$(HOME)/.local/state/less \
		$(HOME)/.local/state/psql \
		$(HOME)/.cache/zsh \
		$(HOME)/.cache/terraform \
		$(HOME)/.config/npm \
		$(HOME)/.config/terraform
	@echo "  dirs    XDG state/cache directories created"

# ── install ───────────────────────────────────────────────────────────────────
install: dirs ## Symlink all dotfiles into place
	$(call link_all,$(LINKS))
	@echo ""
	@echo "Done. Reload your shell:"
	@echo "  fish: source ~/.config/fish/config.fish"
	@echo "  zsh:  source ~/.zshrc"
	@echo "  bash: source ~/.bashrc"
	@echo ""
	@echo "Note: glab-cli/config.yml is NOT symlinked — populate tokens with:"
	@echo "  glab auth login --hostname devops.pnnl.gov"
	@echo "  glab auth login --hostname infra-gitlab.pnl.gov"
	@echo ""
	@echo "Note: oh-my-posh theme (dotconfig/oh-my-posh/custom.omp.json) is backed"
	@echo "  up here but lives at '/mnt/d/OneDrive - PNNL/Documents/custom.omp.json'"
	@echo "  on the Windows side. Copy it there on a fresh machine."

# ── check ─────────────────────────────────────────────────────────────────────
check: ## Show status of all managed symlinks
	@printf "%-55s %s\n" "LINK" "STATUS"
	@printf "%-55s %s\n" "----" "------"
	$(call check_all,$(LINKS))

# ── server profile targets ────────────────────────────────────────────────────
install-server: ## Symlink the server-safe subset (no work identity, no WSL) for a headless machine
	$(call link_all,$(SERVER_LINKS))

check-server: ## Show status of the server profile's symlinks
	@printf "%-55s %s\n" "LINK" "STATUS"
	@printf "%-55s %s\n" "----" "------"
	$(call check_all,$(SERVER_LINKS))

list-server: ## Print the repo files the server profile links (CI checks them for work-specific content)
	@$(foreach pair,$(SERVER_LINKS),echo $(word 2,$(subst |, ,$(pair)));)

# ── internal: create one symlink ──────────────────────────────────────────────
.PHONY: _link
_link:
	@if [ ! -e "$(SRC)" ]; then \
		echo "  ERROR   $(DST) — source not found: $(SRC)"; \
	elif [ -L "$(DST)" ] && [ "$$(readlink "$(DST)")" = "$(SRC)" ]; then \
		echo "  skip    $(DST)"; \
	else \
		if [ -L "$(DST)" ]; then \
			echo "  warn    removing stale symlink $(DST)"; \
			rm "$(DST)"; \
		elif [ -e "$(DST)" ]; then \
			bak="$(DST).bak.$$(date +%Y%m%d%H%M%S)"; \
			echo "  warn    backing up $(DST) -> $$bak"; \
			mv "$(DST)" "$$bak"; \
		fi; \
		mkdir -p "$$(dirname "$(DST)")"; \
		ln -s "$(SRC)" "$(DST)"; \
		echo "  link    $(DST)"; \
	fi

# ── internal: check one symlink ───────────────────────────────────────────────
.PHONY: _check
_check:
	@if [ -L "$(DST)" ] && [ "$$(readlink "$(DST)")" = "$(SRC)" ]; then \
		printf "  %-53s OK\n" "$(DST)"; \
	elif [ -L "$(DST)" ]; then \
		printf "  %-53s WRONG TARGET (-> $$(readlink "$(DST)"))\n" "$(DST)"; \
	elif [ -e "$(DST)" ]; then \
		printf "  %-53s UNMANAGED FILE\n" "$(DST)"; \
	else \
		printf "  %-53s MISSING\n" "$(DST)"; \
	fi

# ── help ──────────────────────────────────────────────────────────────────────
help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*##"}; {printf "  %-10s %s\n", $$1, $$2}'
