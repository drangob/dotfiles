typeset -U path

if [[ -f "$HOME/.cargo/env" ]]; then
  . "$HOME/.cargo/env"
fi

export EDITOR=nvim
export VISUAL=nvim

# macOS only: Askpass helper for sudo (routes password entry through macOS GUI dialog)
if [[ "$OSTYPE" == "darwin"* ]]; then
  export SUDO_ASKPASS="$HOME/.local/bin/claude-sudo-askpass.sh"
  sudo() {
    if [ -t 0 ]; then
      command sudo "$@"
    else
      command sudo -A "$@"
    fi
  }
fi
