#!/usr/bin/env bash
set -e

touch ~/.Xauthority

sudo apt update
sudo apt install -y net-tools curl wget build-essential software-properties-common proxychains
sudo sed -i "$(awk 'NF {last=NR} END {print last}' /etc/proxychains.conf)s/.*/socks5 10.19.138.20 7890/" /etc/proxychains.conf

sudo proxychains add-apt-repository -y ppa:neovim-ppa/unstable
sudo proxychains apt-add-repository -y ppa:fish-shell/release-3
sudo proxychains apt update && sudo apt upgrade -y

sudo proxychains apt install -y git fzf fish neovim

chsh -s /usr/bin/fish
git clone https://github.com/stevalkr/dot_fish.git ~/.config/fish
git clone https://github.com/stevalkr/dot_nvim.git ~/.config/nvim

sh <(curl -L https://nixos.org/nix/install) --no-daemon
