#!/bin/bash

set -e

as_moltbot() {
  sudo -u moltbot "$@"
}

create_user() {
  if [[ ! $(id -u moltbot) ]]; then
    sudo useradd -m moltbot
    sudo usermod -aG sudo moltbot
    sudo passwd -d moltbot
    sudo chsh -s /bin/bash moltbot

    sudo cp -r ~/.ssh /home/moltbot
    sudo chown -R moltbot:moltbot /home/moltbot/.ssh
  fi
}

install_dependencies() {
  sudo install -dm 755 /etc/apt/keyrings
  curl -fSs https://mise.jdx.dev/gpg-key.pub | sudo tee /etc/apt/keyrings/mise-archive-keyring.asc 1> /dev/null
  echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.asc] https://mise.jdx.dev/deb stable main" | sudo tee /etc/apt/sources.list.d/mise.list
  sudo apt update -y
  sudo apt install -y build-essential procps curl file git mise ufw
}

setup_mise() {
  if [[ ! $(which mise) ]]; then
    echo 'eval "$(mise activate bash)"' | sudo -u moltbot tee -a /home/moltbot/.bashrc
  fi

  cp mise.toml /home/moltbot/mise.toml
  chown moltbot:moltbot /home/moltbot/mise.toml
  chmod 644 /home/moltbot/mise.toml

  as_moltbot "cd ~; mise trust"
  as_moltbot "cd ~; mise install"
}

setup_ufw() {
  sudo ufw default deny incoming
  sudo ufw default allow outgoing
  sudo ufw allow ssh
  sudo ufw limit ssh
  sudo ufw enable
}

install_tailscale() {
  curl -fsSL https://tailscale.com/install.sh | sh
}

create_user
install_dependencies
setup_mise
setup_ufw
install_tailscale