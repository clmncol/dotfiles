# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Homebrew initialization (needed for macOS Apple Silicon and non-standard setups)
if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
elif [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate bash)"
fi

# Added by LM Studio CLI (lms)
export PATH="$PATH:$HOME/.lmstudio/bin"
# End of LM Studio CLI section

export TERM=xterm
if [ -f "$HOME/.cargo/env" ]; then
    . "$HOME/.cargo/env"
fi

# UX stuff
eval "$(starship init bash)"
# Bash completion
if [ -f /etc/bash_completion ]; then
  . /etc/bash_completion
fi

# fzf history search (Ctrl+R) as a lightweight alternative to ble.sh inline completions
export FZF_DEFAULT_OPTS="--bind 'ctrl-j:down,ctrl-k:up,j:down,k:up'"
if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --bash 2>/dev/null || true)"
  # Fallback for older fzf versions
  if [ -f /usr/share/fzf/shell/key-bindings.bash ]; then
    . /usr/share/fzf/shell/key-bindings.bash
  elif [ -f /usr/share/doc/fzf/examples/key-bindings.bash ]; then
    . /usr/share/doc/fzf/examples/key-bindings.bash
  elif [ -f ~/.fzf.bash ]; then
    . ~/.fzf.bash
  elif [ -f /opt/homebrew/opt/fzf/shell/key-bindings.bash ]; then
    . /opt/homebrew/opt/fzf/shell/key-bindings.bash
  elif [ -f /usr/local/opt/fzf/shell/key-bindings.bash ]; then
    . /usr/local/opt/fzf/shell/key-bindings.bash
  fi
fi

# vim
alias vi=nvim
alias vim=nvim
set -o vi

# fzf cd into GitHub folder
g() {
  local dir
  dir=$(find ~/GitHub -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sed 's|.*/||' | fzf)
  if [ -n "$dir" ]; then
    cd "$HOME/GitHub/$dir"
  fi
}

alias gg="cd $HOME/GitHub"
# opencode
export PATH="$HOME/.opencode/bin:$PATH"
