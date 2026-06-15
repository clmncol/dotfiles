# .zshrc

# Source global definitions
if [ -f /etc/zshrc ]; then
    . /etc/zshrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.zshrc.d ]; then
    for rc in ~/.zshrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

# Added by LM Studio CLI (lms)
export PATH="$PATH:$HOME/.lmstudio/bin"
# End of LM Studio CLI section

export TERM=xterm
if [ -f "$HOME/.cargo/env" ]; then
    . "$HOME/.cargo/env"
fi

# UX stuff
eval "$(starship init zsh)"

# fzf history search (Ctrl+R) as a lightweight alternative to ble.sh inline completions
export FZF_DEFAULT_OPTS="--bind 'ctrl-j:down,ctrl-k:up,j:down,k:up'"
if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --zsh 2>/dev/null || true)"
  # Fallback for older fzf versions
  if [ -f /usr/share/fzf/shell/key-bindings.zsh ]; then
    . /usr/share/fzf/shell/key-bindings.zsh
  elif [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]; then
    . /usr/share/doc/fzf/examples/key-bindings.zsh
  elif [ -f ~/.fzf.zsh ]; then
    . ~/.fzf.zsh
  elif [ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]; then
    . /opt/homebrew/opt/fzf/shell/key-bindings.zsh
  elif [ -f /usr/local/opt/fzf/shell/key-bindings.zsh ]; then
    . /usr/local/opt/fzf/shell/key-bindings.zsh
  fi
fi

# vim
export EDITOR=nvim
alias vi=nvim
alias vim=nvim
bindkey -v

# opencode
export PATH="$HOME/.opencode/bin:$PATH"
