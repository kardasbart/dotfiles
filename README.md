# dotfiles
dotfiles is a repository to organise all config files for quick workstation setup

# Concept
Idea to make this repo is from https://www.atlassian.com/git/tutorials/dotfiles

# Requirements
* zsh
* oh-my-zsh
* tmux
* feh

# Setup
```
git clone --bare git@github.com:kardasbart/dotfiles.git $HOME/personal/.cfg
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
config checkout
echo "[include]\n\tpath = ~/.gitconfig-common" >> ~/.gitconfig
```
