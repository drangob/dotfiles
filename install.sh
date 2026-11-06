#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ensure Zsh is installed
if ! command -v zsh >/dev/null 2>&1; then
  echo "❌ Error: zsh is not installed. Please install zsh on this machine first."
  exit 1
fi

# Bootstrap Oh-My-Zsh if not present
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "📦 Installing Oh-My-Zsh..."
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# Bootstrap Powerlevel10k theme
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
  echo "🎨 Installing Powerlevel10k theme..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
fi

# Bootstrap custom plugins
clone_plugin() {
  local repo="$1"
  local name="$2"
  if [ ! -d "$ZSH_CUSTOM/plugins/$name" ]; then
    echo "🔌 Installing plugin: $name..."
    git clone --depth=1 "$repo" "$ZSH_CUSTOM/plugins/$name"
  fi
}

clone_plugin https://github.com/zsh-users/zsh-autosuggestions zsh-autosuggestions
clone_plugin https://github.com/agkozak/zsh-z zsh-z
clone_plugin https://github.com/z-shell/F-Sy-H.git F-Sy-H
clone_plugin https://github.com/TamCore/autoupdate-oh-my-zsh-plugins autoupdate

link_file() {
  local src="$1"
  local dst="$2"

  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    echo "Backing up existing $dst -> $dst.backup"
    mv "$dst" "$dst.backup"
  fi
  mkdir -p "$(dirname "$dst")"
  ln -sf "$src" "$dst"
  echo "✔ Linked $dst -> $src"
}

echo "=== Linking dotfiles from $DOTFILES_DIR ==="

# Zsh & Prompt
link_file "$DOTFILES_DIR/zsh/.zshenv" "$HOME/.zshenv"
link_file "$DOTFILES_DIR/zsh/.zprofile" "$HOME/.zprofile"
link_file "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
[ -f "$DOTFILES_DIR/zsh/.p10k.zsh" ] && link_file "$DOTFILES_DIR/zsh/.p10k.zsh" "$HOME/.p10k.zsh"

# Git, Tmux, Vim, SSH
link_file "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
link_file "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
[ -f "$DOTFILES_DIR/vim/.vimrc" ] && link_file "$DOTFILES_DIR/vim/.vimrc" "$HOME/.vimrc"
link_file "$DOTFILES_DIR/ssh/config" "$HOME/.ssh/config"

# Neovim (Single folder link)
if [ -d "$DOTFILES_DIR/config/nvim" ]; then
  if [ -e "$HOME/.config/nvim" ] && [ ! -L "$HOME/.config/nvim" ]; then
    echo "Backing up existing ~/.config/nvim -> ~/.config/nvim.backup"
    mv "$HOME/.config/nvim" "$HOME/.config/nvim.backup"
  fi
  mkdir -p "$HOME/.config"
  ln -sf "$DOTFILES_DIR/config/nvim" "$HOME/.config/nvim"
  echo "✔ Linked $HOME/.config/nvim -> $DOTFILES_DIR/config/nvim"
fi

# Tool versioning
link_file "$DOTFILES_DIR/config/mise/config.toml" "$HOME/.config/mise/config.toml"
command -v mise >/dev/null 2>&1 || echo "⚠ mise is not installed: brew install mise"

# Work dotfiles (private submodule, opt-in per machine)
if [ ! -f "$DOTFILES_DIR/work/zprofile" ]; then
  read -rp "Pull the private work dotfiles (needs access to drangob/dotfiles-work)? [y/N] " pull_work
  if [[ "$pull_work" =~ ^[Yy] ]]; then
    git -C "$DOTFILES_DIR" submodule update --init --checkout work || echo "⚠ Couldn't pull the work dotfiles, skipping"
  fi
fi
if [ -f "$DOTFILES_DIR/work/zprofile" ]; then
  link_file "$DOTFILES_DIR/work/zprofile" "$HOME/.zprofile.local"
  link_file "$DOTFILES_DIR/work/mise.toml" "$HOME/.config/mise/conf.d/multiverse.toml"
fi

# ~/.config tools
[ -f "$DOTFILES_DIR/config/ghostty/config" ] && link_file "$DOTFILES_DIR/config/ghostty/config" "$HOME/.config/ghostty/config"
[ -f "$DOTFILES_DIR/config/zed/settings.json" ] && link_file "$DOTFILES_DIR/config/zed/settings.json" "$HOME/.config/zed/settings.json"
[ -f "$DOTFILES_DIR/config/gh/config.yml" ] && link_file "$DOTFILES_DIR/config/gh/config.yml" "$HOME/.config/gh/config.yml"
[ -f "$DOTFILES_DIR/config/btop/btop.conf" ] && link_file "$DOTFILES_DIR/config/btop/btop.conf" "$HOME/.config/btop/btop.conf"

# macOS-only scripts (the askpass dialog is used by the sudo wrapper in .zshenv)
if [[ "$OSTYPE" == "darwin"* ]]; then
  link_file "$DOTFILES_DIR/bin/claude-sudo-askpass.sh" "$HOME/.local/bin/claude-sudo-askpass.sh"
  link_file "$DOTFILES_DIR/bin/sign-app" "$HOME/.local/bin/sign-app"
fi

# Bootstrap Codex CLI if not present
if ! command -v codex >/dev/null 2>&1 && [ ! -f "$HOME/.local/bin/codex" ]; then
  echo "🤖 Installing Codex CLI..."
  sh -c 's=$(curl -fsSL https://chatgpt.com/codex/install.sh) && CODEX_NON_INTERACTIVE=1 eval "$s"' || true
fi

# Setup ~/.gitconfig.local interactively if missing
if [ ! -f "$HOME/.gitconfig.local" ]; then
  echo ""
  echo "--- Local Git Identity Setup (~/.gitconfig.local) ---"
  read -rp "Enter Git Name: " git_name
  read -rp "Enter Git Email: " git_email
  read -rp "Enter Git SSH Signing Key (optional, press Enter to skip): " git_key

  if [[ "$OSTYPE" == "darwin"* ]]; then
    op_sign="/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
  else
    op_sign="/opt/1Password/op-ssh-sign"
  fi

  cat << CONF > "$HOME/.gitconfig.local"
# Local machine-specific overrides
[user]
	name = $git_name
	email = $git_email
$([ -n "$git_key" ] && echo -e "	signingkey = $git_key")

[gpg "ssh"]
	program = "$op_sign"
CONF
  echo "✔ Created ~/.gitconfig.local"
fi

# Setup empty ~/.zsh_secrets template (with chmod 600) if missing
if [ ! -f "$HOME/.zsh_secrets" ]; then
  cat << 'SECRETS' > "$HOME/.zsh_secrets"
# ~/.zsh_secrets (LOCAL ONLY - NEVER COMMITTED TO GIT)
# Add your local API tokens, keys, and private environment variables below:
# export GH_TOKEN="ghp_..."
# export LINEAR_API_KEY="lin_api_..."
# export OPENAI_KEY="sk-..."
SECRETS
  chmod 600 "$HOME/.zsh_secrets"
  echo "✔ Created empty ~/.zsh_secrets template (chmod 600)"
fi

echo ""
echo "✔ All dotfiles linked successfully!"
