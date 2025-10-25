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
alias config='/usr/bin/git --git-dir=$HOME/personal/.cfg/ --work-tree=$HOME'
config checkout -f
echo "[include]\n\tpath = ~/.gitconfig-common" >> ~/.gitconfig

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
# Inside tmux: Press prefix + I (capital i, as in Install) to fetch the plugin.
```
