#!/usr/bin/env bash
set -e

# Ask if the user wants to install nix
echo "Install nix? [y]/n:"
read install_nix

# Ask if the user wants to use proxychains
echo "Use proxychains? [y]/n:"
read use_proxychains

if [[ "$use_proxychains" == "y" || "$use_proxychains" == "Y" || -z "$use_proxychains" ]]; then
    echo "Enter the proxy info for proxychains.conf (e.g., socks5 10.19.138.20 7890 user password):"
    read user_input
fi

# Define a helper function to run commands with or without proxychains
run_command() {
    if [[ "$use_proxychains" == "y" || "$use_proxychains" == "Y" || -z "$use_proxychains" ]]; then
        sudo proxychains "$@"
    else
        sudo "$@"
    fi
}

touch ~/.Xauthority

sudo apt update
sudo apt install -y net-tools curl wget build-essential software-properties-common

# Install and configure proxychains
if [[ "$use_proxychains" == "y" || "$use_proxychains" == "Y" || -z "$use_proxychains" ]]; then
    sudo apt install -y proxychains
    sudo sed -i "$(awk 'NF {last=NR} END {print last}' /etc/proxychains.conf)s/.*/$user_input/" /etc/proxychains.conf
fi

# Conditionally use proxychains to install packages
run_command add-apt-repository -y ppa:neovim-ppa/unstable
run_command apt-add-repository -y ppa:fish-shell/release-4
run_command curl -fsSL https://deb.nodesource.com/setup_23.x -o /tmp/nodesource_setup.sh
run_command sudo -E bash /tmp/nodesource_setup.sh
run_command apt update && run_command apt upgrade -y
run_command apt install -y git fzf fish nodejs unzip codespell neovim libreadline-dev

# Change default shell to fish
chsh -s /usr/bin/fish

# Clone Git repositories for fish and neovim configurations
git clone https://github.com/stevalkr/dot_fish.git ~/.config/fish
git clone https://github.com/stevalkr/dot_nvim.git ~/.config/nvim

# Install Nix package manager
if [[ "$install_nix" == "y" || "$install_nix" == "Y" || -z "$install_nix" ]]; then
    sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --no-daemon --yes
    mkdir -p ~/.config/nix
    cat > ~/.config/nix/nix.conf<< EOF
max-jobs = auto
keep-outputs = true
keep-derivations = true
auto-allocate-uids = true
extra-experimental-features = nix-command flakes auto-allocate-uids configurable-impure-env

substituters = https://cache.nixos.org https://cuda-maintainers.cachix.org https://ros.cachix.org
trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E= ros.cachix.org-1:dSyZxI8geDCJrwgvCOHDoAfOm5sV1wCPjBkKL+38Rvo=
EOF
    echo "Nix installed successfully. You may want to add `access-tokens` to ~/.config/nix/nix.conf for github access."
fi

