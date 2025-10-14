#!/bin/bash

# Simple Dotfiles Bootstrap Script
# Clones the repo and sets up symlinks

# Variables
REPO_SSH="git@github.com:KushalMeghani1644/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"

# 1. Clone the repo if it doesn't exist
if [ -d "$DOTFILES_DIR" ]; then
    echo "Dotfiles directory already exists at $DOTFILES_DIR"
else
    echo "Cloning dotfiles repository..."
    git clone "$REPO_SSH" "$DOTFILES_DIR" || { echo "Failed to clone repo"; exit 1; }
fi

# 2. Create symbolic links
echo "Creating symbolic links..."

# Neovim
mkdir -p "$HOME/.config/nvim"
ln -sf "$DOTFILES_DIR/nvim/init.lua" "$HOME/.config/nvim/init.lua"

# Tmux
ln -sf "$DOTFILES_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"

# Vim
ln -sf "$DOTFILES_DIR/vim/vimrc" "$HOME/.vimrc"

echo "All done! Your dotfiles are now set up."

