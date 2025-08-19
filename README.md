# dotfiles
dotfiles is a repository to organise all config files for quick workstation setup

# Concept
Idea to make this repo is from https://www.atlassian.com/git/tutorials/dotfiles

# Requirements
* zsh
* oh-my-zsh [installation](https://github.com/ohmyzsh/ohmyzsh?tab=readme-ov-file#basic-installation)
* ZSH syntax highlighting [installation](https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/INSTALL.md#oh-my-zsh)
* ZSH Autosuggestions [installation](https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/INSTALL.md#oh-my-zsh)
* tmux
* Tmux Plugin Manager [installation](https://github.com/tmux-plugins/tpm?tab=readme-ov-file#installation)
* feh

# Setup
```
git clone --bare git@github.com:kardasbart/dotfiles.git $HOME/.cfg
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
config checkout
```
