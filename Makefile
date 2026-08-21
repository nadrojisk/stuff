REPO  := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
DOT   := $(REPO)/dotconfig
HOME  := $(HOME)

# ── symlink targets ───────────────────────────────────────────────────────────
# Each entry is: <dst>|<src>
LINKS := \
	$(HOME)/.gitconfig|$(DOT)/git/.gitconfig \
	$(HOME)/.gitconfig-wsl|$(DOT)/git/.gitconfig-wsl \
	$(HOME)/.config/git/ignore|$(DOT)/git/xdg/ignore \
	$(HOME)/.bashrc|$(DOT)/bash/.bashrc \
	$(HOME)/.config/fish/config.fish|$(DOT)/fish/config.fish \
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
	$(HOME)/.config/timewarrior/timewarrior.cfg|$(DOT)/timewarrior/timewarrior.cfg

.PHONY: install check help

# ── install ───────────────────────────────────────────────────────────────────
install: ## Symlink all dotfiles into place
	@$(foreach pair,$(LINKS), \
		$(eval dst := $(word 1,$(subst |, ,$(pair)))) \
		$(eval src := $(word 2,$(subst |, ,$(pair)))) \
		$(MAKE) --no-print-directory _link DST=$(dst) SRC=$(src) ;)
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
	@$(foreach pair,$(LINKS), \
		$(eval dst := $(word 1,$(subst |, ,$(pair)))) \
		$(eval src := $(word 2,$(subst |, ,$(pair)))) \
		$(MAKE) --no-print-directory _check DST=$(dst) SRC=$(src) ;)

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
