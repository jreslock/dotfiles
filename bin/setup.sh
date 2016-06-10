#!/bin/bash -eux

# Get Homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install packages
brew install $(cat ../packages/brews) || true

# Install casks
brew cask install $(cat ../packages/casks) || true

# Install python modules (use sudo because no virutalenv yet)
sudo pip install virtualenvwrapper thefuck

# Clean up existing stuff, if any.
rm -fr /usr/local/share/antigen
rm -fr ~/.vim/bundle

# Get vundle for vim stuff
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

# Get Antigen
git clone https://github.com/zsh-users/antigen /usr/local/share/antigen

# Remove default dotfiles and symlink to new ones.
files=(".zshrc" ".vimrc" ".gitconfig" ".git-commit-template")

for file in $files
do
  if [ -f ~/$file ] ; then
    rm -f ~/$file
  fi
  ln -s ~/dotfiles/configs/$file ~/$file
done

# Install the vim Vundle plugins
vim +PluginInstall +qall

# Make an envs dir for virtualenvwrapper
dirs=("~/Envs")

for dir in $dirs
do
  if [ ! -d "$dir" ] ; then
    mkdir -p "$dir"
  fi
done

# Source the new .zshrc by simply switching shells
zsh