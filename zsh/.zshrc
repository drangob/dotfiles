# Ensure Homebrew is in PATH if not already loaded from .zprofile
if ! command -v brew >/dev/null 2>&1; then
  if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
    autoupdate
    sudo
    safe-paste
    git
    zsh-autosuggestions
    zsh-z
    F-Sy-H
)
if [[ "$OSTYPE" == "darwin"* ]]; then
    plugins+=(macos)
fi

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
# Kept above oh-my-zsh so its compinit picks them up, instead of Docker's own second compinit.
fpath=($HOME/.docker/completions $fpath)
# End of Docker CLI completions

source $ZSH/oh-my-zsh.sh

if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi
# autosuggestions' zpty-based async fetch silently fails under Ghostty; sync mode is fine for this history size
unset ZSH_AUTOSUGGEST_USE_ASYNC

alias vim="nvim"
alias vi="nvim"

if [[ "$TERM_PROGRAM" == "vscode" ]]; then
  export GH_EDITOR="code --wait"
fi

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

if [[ "$OSTYPE" == "darwin"* ]]; then
    export SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    export SSH_AUTH_SOCK="$HOME/.1password/agent.sock"
    # Normalize Bazzite /var/home path so prompt displays ~
    if [[ "$PWD" == "/var/home/$USER"* ]]; then
        cd "/home/$USER${PWD#/var/home/$USER}"
    fi
fi

[[ -f "$HOME/.config/op/plugins.sh" ]] && source "$HOME/.config/op/plugins.sh"

if [ -f ~/.fzf.zsh ]; then
  source ~/.fzf.zsh
elif [ -f /usr/share/fzf/shell/key-bindings.zsh ]; then
  source /usr/share/fzf/shell/key-bindings.zsh
fi

export PATH=$HOME/.local/bin:$PATH

export PATH=$HOME/.opencode/bin:$PATH
