# dotfiles
dotfiles is a repository to organise all config files for quick workstation setup

# Concept
Idea to make this repo is from https://www.atlassian.com/git/tutorials/dotfiles

# Setup
```
git clone --bare <git-repo-url> $HOME/.cfg
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
config checkout
```
# Requirements
* zsh
* oh-my-zsh
* tmux
* feh
