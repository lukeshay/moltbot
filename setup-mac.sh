#!/bin/bash

set -e

require_cli() {
  if [[ ! $(which $1) ]]; then
    echo "Error: $1 is not installed"
    exit 1
  fi
}

verify_dependencies() {
  require_cli "docker"
}

install_homebrew() {
  if [[ ! $(which brew) ]]; then
    curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | sh
  fi
}

install_mise() {
  if [[ ! $(which mise) ]]; then
    echo 'eval "$(mise activate bash)"' >> ~/.bashrc
    eval "$(mise activate bash)"
  fi
  
  cp mise.toml ~/mise.toml
  chown "${USER}:${USER}" ~/mise.toml
  chmod 644 ~/mise.toml

  pushd ~
  mise trust
  mise install
  popd
}

install_dependencies() {
  brew install mise fail2ban
  brew install --cask tailscale-app
  npm i -g moltbot@latest
}

setup_pf() {
  # Create PF anchor file for custom rules
  PF_ANCHOR="/etc/pf.anchors/moltbot"
  sudo mkdir -p /etc/pf.anchors
  
  # PF rules: block all incoming by default, allow outgoing, allow Tailscale traffic
  sudo tee "$PF_ANCHOR" > /dev/null <<'EOF'
# Default policy: block all incoming, allow all outgoing
block in all
pass out all

# Allow all traffic on Tailscale interface
pass in on tailscale0

# Allow HTTP/HTTPS from Tailscale network (100.64.0.0/10)
pass in proto tcp from 100.64.0.0/10 to any port { 80, 443 }
EOF

  # Test the rules syntax
  sudo pfctl -f "$PF_ANCHOR" -n
  
  # Enable PF if not already enabled
  if ! sudo pfctl -s info 2>/dev/null | grep -q "Enabled"; then
    sudo pfctl -e
  fi
  
  # Load the rules
  sudo pfctl -f "$PF_ANCHOR"
}

setup_fail2ban() {
  sudo brew services start fail2ban
}

setup_tailscale() {
  sudo /Applications/Tailscale.app/Contents/MacOS/Tailscale up
}

print_instructions() {
  echo "Setup complete. Please follow the instructions to complete the setup."
  echo "1. Login to Tailscale by opening the Tailscale app in the menu bar"
  echo "2. Update ssh config with the following:"
  echo "  sudo vim /etc/ssh/sshd_config"
  echo "    # Set explicitly:"
  echo "    PasswordAuthentication no"
  echo "    PermitRootLogin no"
  echo "3. Restart ssh service:"
  echo "    sudo launchctl unload /System/Library/LaunchDaemons/ssh.plist"
  echo "    sudo launchctl load -w /System/Library/LaunchDaemons/ssh.plist"
  echo "4. Add your public key to the authorized_keys file:"
  echo "    sudo vim ${HOME}/.ssh/authorized_keys"
  echo "5. Setup moltbot:"
  echo "    moltbot onboard --install-daemon"
}

verify_dependencies
install_homebrew
install_mise
install_dependencies
setup_pf
setup_fail2ban
setup_tailscale

print_instructions
