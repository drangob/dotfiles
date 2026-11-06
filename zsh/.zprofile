# Set PATH, MANPATH, etc., for Homebrew dynamically based on OS
if [[ -f "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Shims rather than `mise activate`: activate only hooks interactive prompts, so hooks, MCP servers and GUI-launched apps would get no tools.
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh --shims)"
fi

if [[ -f "$HOME/.zprofile.local" ]]; then
  source "$HOME/.zprofile.local"
fi

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
