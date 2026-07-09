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
mkdir -p ~/.config/ghostty
cp -f ghostty/config ~/.config/ghostty/config

# herdr
mkdir -p ~/.config/herdr
cp -f herdr/config.toml ~/.config/herdr/config.toml

# claude
mkdir -p ~/.claude
cp -f claude/statusline-command.sh ~/.claude/statusline-command.sh

# cursor (macOS only)
if [ "$(uname)" = "Darwin" ]; then
  cp -f cursor/settings.json ~/Library/Application\ Support/Cursor/User/settings.json
  cp -f cursor/keybindings.json ~/Library/Application\ Support/Cursor/User/keybindings.json
fi
