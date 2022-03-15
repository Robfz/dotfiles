#!/bin/bash
sudo chsh -s $(which zsh) $(whoami)

if command -v apt > /dev/null; then
  sudo apt install tmux -y
fi

cp -f .tmux.conf ~/.tmux.conf
cp -f .vimrc ~/.vimrc
cp -f .zshrc ~/.zshrc
