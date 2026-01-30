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
  command -v brew >/dev/null 2>&1 || curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | sh

  brew install mise fail2ban ollama
  brew install --cask tailscale-app
  npm i -g openclaw@latest
  
  if ! grep -q 'eval "$(mise activate zsh)"' ~/.zshrc 2>/dev/null; then
    echo 'eval "$(mise activate zsh)"' >> ~/.zshrc
  fi
  eval "$(mise activate zsh)"
  
  cp mise.toml ~/mise.toml
  chmod 644 ~/mise.toml

  (cd ~ && mise trust && mise install)
}

setup_pf() {
  PF_ANCHOR="/etc/pf.anchors/moltbot"
  sudo mkdir -p /etc/pf.anchors
  
  sudo tee "$PF_ANCHOR" > /dev/null <<'EOF'
block in all
pass out all
pass in on tailscale0
pass in proto tcp from 100.64.0.0/10 to any port { 80, 443 }
EOF

  sudo pfctl -f "$PF_ANCHOR" -n
  sudo pfctl -s info 2>/dev/null | grep -q "Enabled" || sudo pfctl -e
  sudo pfctl -f "$PF_ANCHOR"
}

setup_ollama() {
  brew services start ollama
  ollama pull kimi-k2.5:cloud
}

setup_fail2ban() {
  brew services start fail2ban
}

setup_tailscale() {
  sudo /Applications/Tailscale.app/Contents/MacOS/Tailscale up \
    --auth-key "${TAILSCALE_AUTH_KEY}" \
    --hostname "${TAILSCALE_HOSTNAME:-$(hostname)}"
}

print_instructions() {
  cat <<EOF
Setup complete. Next steps:
1. Configure SSH: sudo vim /etc/ssh/sshd_config
   Set: PasswordAuthentication no
2. Add your public key: sudo vim ${HOME}/.ssh/authorized_keys
3. Setup moltbot: moltbot onboard --install-daemon
EOF
}

install_dependencies
setup_pf
setup_fail2ban
setup_ollama
setup_tailscale
print_instructions
