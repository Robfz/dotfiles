#!/bin/bash
sudo chsh -s $(which zsh) $(whoami)

if command -v apt > /dev/null; then
  sudo apt install tmux -y
fi

# tmux
cp -f .tmux.conf ~/.tmux.conf
mkdir -p ~/.tmux/conf.d
cp -f .tmux/conf.d/*.conf ~/.tmux/conf.d/

# vim / neovim
cp -f .vimrc ~/.vimrc
mkdir -p ~/.config/nvim
cp -Rf nvim/. ~/.config/nvim/

# zsh
cp -f zsh/zshrc ~/.zshrc

# ghostty
mkdir -p ~/.config/ghostty/themes
cp -f ghostty/config ~/.config/ghostty/config
cp -f ghostty/themes/* ~/.config/ghostty/themes/

# zed
mkdir -p ~/.config/zed/themes
cp -f zed/settings.json ~/.config/zed/settings.json
cp -f zed/keymap.json ~/.config/zed/keymap.json
cp -f zed/themes/* ~/.config/zed/themes/

# herdr
mkdir -p ~/.config/herdr
cp -f herdr/config.toml ~/.config/herdr/config.toml

# claude
mkdir -p ~/.claude
cp -f claude/statusline-command.sh ~/.claude/statusline-command.sh

# pi (delegates to sibling pi-extensions repo, if cloned)
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
PI_EXTENSIONS_DIR="$DOTFILES_DIR/../pi-extensions"
if [ -d "$PI_EXTENSIONS_DIR" ]; then
  bash "$PI_EXTENSIONS_DIR/scripts/link.sh"
  if command -v jq > /dev/null; then
    bash "$PI_EXTENSIONS_DIR/scripts/apply-settings.sh"
  else
    echo "pi: jq not found; skipping apply-settings.sh"
  fi
else
  echo "pi: ../pi-extensions not found; skipping (git clone git@github.com:Robfz/pi-extensions.git next to dotfiles)"
fi

# pi coding agent (macOS: homebrew node, wrapper bypasses mise/asdf shims — see docs/pi.md)
if [ "$(uname)" = "Darwin" ] && [ -x /opt/homebrew/bin/node ]; then
  PATH="/opt/homebrew/bin:$PATH" /opt/homebrew/bin/npm install -g @earendil-works/pi-coding-agent
  mkdir -p ~/.local/bin
  cp -f bin/pi ~/.local/bin/pi
  cp -f bin/pi-npm ~/.local/bin/pi-npm
  # let pi's self-update and extension installs run npm without mise/asdf node resolution
  if command -v jq > /dev/null; then
    mkdir -p ~/.pi/agent
    [ -f ~/.pi/agent/settings.json ] || echo '{}' > ~/.pi/agent/settings.json
    jq --arg cmd "$HOME/.local/bin/pi-npm" '.npmCommand = [$cmd]' \
      ~/.pi/agent/settings.json > ~/.pi/agent/settings.json.tmp && mv ~/.pi/agent/settings.json.tmp ~/.pi/agent/settings.json
  else
    echo "pi: jq not found; skipping npmCommand setting (pi update/extension installs may fail in folders without a pinned node)"
  fi
else
  echo "pi: homebrew node not found; skipping pi install"
fi

# cursor (macOS only)
if [ "$(uname)" = "Darwin" ]; then
  cp -f cursor/settings.json ~/Library/Application\ Support/Cursor/User/settings.json
  cp -f cursor/keybindings.json ~/Library/Application\ Support/Cursor/User/keybindings.json
fi
