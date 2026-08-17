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

## Automated Setup (Recommended)

Run the installation script directly from GitHub using `wget` (pre-installed on Ubuntu 24.04):

```bash
wget -qO- [https://raw.githubusercontent.com/kardasbart/dotfiles/main/setup.sh](https://raw.githubusercontent.com/kardasbart/dotfiles/main/setup.sh) | bash

```

## Manual Setup

```bash
# Install requirements
sudo apt update && sudo apt install -y zsh tmux feh curl git
sh -c "$(curl -fsSL [https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh](https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh))"
chsh -s $(which zsh)

# Clone dotfiles bare repository
git clone --bare [https://github.com/kardasbart/dotfiles.git](https://github.com/kardasbart/dotfiles.git) $HOME/personal/.cfg
alias config='/usr/bin/git --git-dir=$HOME/personal/.cfg/ --work-tree=$HOME'

# Configure sparse-checkout to avoid cluttering $HOME with repository files
config config status.showUntrackedFiles no
config sparse-checkout init --no-cone
config sparse-checkout set --no-cone '/*' '!/README.md' '!/setup.sh' '!/test.sh' '!/Dockerfile'
config checkout -f

# Git configuration
git config --global include.path "~/.gitconfig-common"

# Install Zsh plugins & Tmux Plugin Manager
git clone [https://github.com/zsh-users/zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone [https://github.com/zsh-users/zsh-syntax-highlighting.git](https://github.com/zsh-users/zsh-syntax-highlighting.git) ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

git clone [https://github.com/tmux-plugins/tpm](https://github.com/tmux-plugins/tpm) ~/.tmux/plugins/tpm
# Inside tmux: Press prefix + I (capital i, as in Install) to fetch the plugin.

```

# Testing

You can verify the entire setup inside an isolated container using either **Podman** (recommended for a lightweight, rootless setup) or **Docker**.

### Option A: Podman (Lightweight)

```bash
# Install Podman
sudo apt update && sudo apt install -y podman

# Build and run the test suite
podman build -t dotfiles-test .
podman run --rm dotfiles-test

```

### Option B: Docker

```bash
# Install Docker
sudo apt update && sudo apt install -y docker.io

# Build and run the test suite
docker build -t dotfiles-test .
docker run --rm dotfiles-test

```