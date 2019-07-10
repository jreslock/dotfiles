#!/bin/bash -eux

# Get Homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Make sure brew is updated
brew update

# Install packages
brew install "$(cat ../packages/brews)" || true

# Install casks
brew cask install "$(cat ../packages/casks)" || true

# Clean up existing stuff, if any.
rm -fr /usr/local/share/antigen

# Get Antigen
git clone https://github.com/zsh-users/antigen /usr/local/share/antigen

for file in $(.zshrc .gitconfig .git-commit-template)
do
  if [ -f ~/"$file" ] ; then
    rm -f ~/"$file"
  fi
  ln -s "$HOME"/code/dotfiles/configs/"$file" "$HOME"/"$file"
done

# Source the new .zshrc by simply switching shells
zsh