#!/usr/bin/env bash
set -e

touch ~/.Xauthority

sudo apt update
sudo apt install -y net-tools curl wget build-essential software-properties-common
sudo add-apt-repository -y ppa:neovim-ppa/unstable
sudo apt-add-repository -y ppa:fish-shell/release-3
sudo apt update && sudo apt upgrade -y

sudo apt install -y git fzf fish neovim

chsh -s /usr/bin/fish
git clone https://github.com/stevalkr/dot_fish.git ~/.config/fish
git clone https://github.com/stevalkr/dot_nvim.git ~/.config/nvim

