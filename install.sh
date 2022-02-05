#!/bin/bash
sudo chsh -s $(which zsh) $(whoami)

if command -v apt > /dev/null
  sudo apt install tmux -y
end

