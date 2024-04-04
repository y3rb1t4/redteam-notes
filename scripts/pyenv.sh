#!/bin/zsh

# Install pyenv
echo "Installing pyenv..."
curl https://pyenv.run | zsh

# Add pyenv configuration to ~/.zshrc
echo "Updating zshrc..."
cat << 'EOF' >> ~/.zshrc

# Pyenv configuration
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
EOF

# Apply changes to current session
source ~/.zshrc

# Install pyenv-virtualenv
echo "Installing pyenv-virtualenv..."
git clone https://github.com/pyenv/pyenv-virtualenv.git "$(pyenv root)"/plugins/pyenv-virtualenv

# Add pyenv-virtualenv configuration to ~/.zshrc
echo "Updating zshrc for pyenv-virtualenv..."
cat << 'EOF' >> ~/.zshrc

# Pyenv-virtualenv configuration
eval "$(pyenv virtualenv-init -)"
EOF

# Apply changes to current session
source ~/.zshrc

echo "Installation complete. Please restart your terminal for the changes to take effect."
