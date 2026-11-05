# Set PATH, MANPATH, etc., for Homebrew dynamically based on OS
if [[ -f "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Prefer asdf-managed tools in login shells, including non-interactive commands.
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

export BUILD_PIPELINE_FROM_FAILED=true
export GH_HOST=github.com
export WITH_REAL_AUTHENTICATION_SERVICE=false

# Source local private secrets (API tokens, auth keys - not tracked in Git)
if [[ -f "$HOME/.zsh_secrets" ]]; then
  source "$HOME/.zsh_secrets"
fi

# Only set when in vscode
if [[ "$TERM_PROGRAM" == "vscode" ]]; then
  export GH_EDITOR="code --wait"
fi

# macOS-specific aliases
if [[ "$OSTYPE" == "darwin"* ]]; then
  alias vlc='/Applications/VLC.app/Contents/MacOS/VLC'
fi


export PATH="$HOME/.local/bin:$PATH"
