#!/bin/bash

set -e

create_user() {
  if [[ ! $(id -u moltbot) ]]; then
    useradd -m moltbot
    sudo usermod -aG sudo moltbot
    passwd -d moltbot
    cp -r ~/.ssh /home/moltbot
    chown -R moltbot:moltbot /home/moltbot/.ssh
  fi
}

install_dependencies() {
  sudo apt update -y
  sudo apt install -y build-essential procps curl file git
}

install_mise() {
  if [[ ! $(which mise) ]]; then
    sudo install -dm 755 /etc/apt/keyrings
    curl -fSs https://mise.jdx.dev/gpg-key.pub | sudo tee /etc/apt/keyrings/mise-archive-keyring.asc 1> /dev/null
    echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.asc] https://mise.jdx.dev/deb stable main" | sudo tee /etc/apt/sources.list.d/mise.list
    sudo apt update -y
    sudo apt install -y mise
  fi

  cp mise.toml /home/moltbot/mise.toml
  chown moltbot:moltbot /home/moltbot/mise.toml
  chmod 644 /home/moltbot/mise.toml
  sudo -u moltbot mise sync
  sudo -u moltbot mise install
}

create_user
install_dependencies
install_mise

pnpm add -g moltbot@latest