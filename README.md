# Dotfiles

## Description

A set of dotfiles and a script to set them up along with standard tools for a MacOS development system.

I use antigen to configure/manage oh-my-zsh.

The code editor du jour is vscode with several helpful extensions for python and terraform development.

The gpg tools and pinentry are for using a yubikey for ssh authentication to github.  

## Usage

It is fairly simple to get this working on a new system.  Change the email and home directory path in .gitconfig before running setup.sh.  I keep all of my git repos in ~/code and the setup.sh creates symlinks with this assumption.  If you keep code in a different location be sure to change the symlink code in bin/setup.sh line 26 to your preferred code location.

    cd ~/code
    git clone git@github.com:jreslock/dotfiles
    cd dotfiles/bin
    ./setup.sh

There will likely be other things to install such as editor extensions, a python virtual environment, some pip packages, etc.  This repository is meant to be a starting point that allows for quick setup of a development system from a clean MacOS.
