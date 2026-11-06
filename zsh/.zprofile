if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Shims, not `mise activate`: activate only hooks interactive prompts, so hooks, MCP servers and GUI apps would get no tools.
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh --shims)"
fi

export PATH="$HOME/.local/bin:$PATH"

[[ -f "$HOME/.zprofile.local" ]] && source "$HOME/.zprofile.local"
[[ -f "$HOME/.zsh_secrets" ]] && source "$HOME/.zsh_secrets"
