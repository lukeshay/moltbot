#!/bin/bash

set -e

require_env() {
  local var_name="$1"
  if [ -z "${!var_name}" ]; then
    echo "Error: Environment variable '$var_name' is not set."
    exit 1
  fi
}

require_env "TAILSCALE_AUTH_KEY"

install_dependencies() {
  sudo apt update -y
  sudo apt upgrade -y
  sudo apt install -y build-essential curl git procps file

  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Detect brew installation path
  if [ -d "/home/linuxbrew/.linuxbrew" ]; then
    BREW_PATH="/home/linuxbrew/.linuxbrew"
  elif [ -d "$HOME/.linuxbrew" ]; then
    BREW_PATH="$HOME/.linuxbrew"
  else
    echo "Error: Could not find Homebrew installation"
    exit 1
  fi

  echo "eval \"\$($BREW_PATH/bin/brew shellenv)\"" >> ~/.bashrc
  eval "$($BREW_PATH/bin/brew shellenv)"

  brew install mise tailscale ollama
}

setup_mise() {
  if [ -f "mise.toml" ]; then
    cp mise.toml ~/mise.toml
  else
    echo "Warning: mise.toml not found in current directory"
  fi

  pushd ~
  mise trust
  mise install
  popd
}

setup_tailscale() {
  tailscale up --auth-key "${TAILSCALE_AUTH_KEY}"
}

setup_ufw() {
  sudo ufw default deny incoming
  sudo ufw default allow outgoing
  sudo ufw allow in on tailscale0
  sudo ufw allow from 100.64.0.0/10 to any port 443 proto tcp
  sudo ufw allow from 100.64.0.0/10 to any port 80 proto tcp
  sudo ufw allow from 100.64.0.0/10 to any port 22 proto tcp
  sudo ufw --force enable
}

setup_ollama() {
  ollama pull kimi-k2.5:cloud
}

install_openclaw() {
  npm install -g openclaw@latest
}

install_dependencies
setup_mise
setup_tailscale
setup_ufw
setup_ollama
install_openclaw