#!/usr/bin/env bash

# Zatrzymuje skrypt w przypadku krytycznego błędu, ale pozwala na kontrolowane błędy w warunkach (if)
set -e

REPO_SRC="https://github.com/kardasbart/dotfiles.git"
SERVER_MODE=0

while [[ $# -gt 0 ]]; do
  case $1 in
    --local|-l)
      REPO_SRC="${2:-$PWD}"
      shift 2
      ;;
    --server|-s)
      SERVER_MODE=1
      shift
      ;;
    *)
      shift
      ;;
  esac
done

echo "=========================================="
echo " Starting workstation setup script..."
if [ "$SERVER_MODE" -eq 1 ]; then
    echo " Mode: SERVER (No root, skipping apt installation)"
else
    echo " Mode: DESKTOP (With sudo apt installation)"
fi
echo "=========================================="

# 1. Zależności (Tylko w trybie Desktop)
if [ "$SERVER_MODE" -eq 0 ]; then
    echo "==> Updating package lists and installing dependencies..."
    sudo apt update
    sudo apt install -y zsh tmux feh curl git mpv
fi

# 2. Sprawdzenie krytycznych narzędzi (żeby skrypt nie padł w połowie)
for cmd in git zsh tmux curl; do
    if ! command -v $cmd >/dev/null 2>&1; then
        echo "OSTRZEŻENIE: Brak zainstalowanego programu '$cmd'. Instalacja może być niepełna."
    fi
done

# 3. Instalacja Oh My Zsh
echo "==> Installing Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    # Błędy przy curl/git nie wysadzą całego skryptu dzięki obsłudze ||
    git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh" || echo "Błąd pobierania Oh My Zsh."
    if [ ! -f "$HOME/.zshrc" ] && [ -f "$HOME/.oh-my-zsh/templates/zshrc.zsh-template" ]; then
        cp "$HOME/.oh-my-zsh/templates/zshrc.zsh-template" "$HOME/.zshrc"
    fi
else
    echo "Oh My Zsh is already installed."
fi

# 4. Ustawienie Zsh jako domyślnej powłoki
echo "==> Setting Zsh as the default shell..."
if command -v zsh >/dev/null 2>&1; then
    ZSH_PATH=$(command -v zsh)
    if [ "$SHELL" != "$ZSH_PATH" ]; then
        if [ "$SERVER_MODE" -eq 0 ]; then
            sudo chsh -s "$ZSH_PATH" "$(whoami)" || echo "Nie udało się zmienić powłoki za pomocą sudo."
        else
            echo "Próbuję zmienić domyślną powłokę (bez sudo)..."
            if ! chsh -s "$ZSH_PATH"; then
                echo "UWAGA: chsh odrzuciło powłokę (prawdopodobnie brak wpisu w /etc/shells)."
                echo "Konfiguruję automatyczny fallback do Zsh w ~/.bashrc..."
                
                # Bezpieczny skrypt przełączający
                BASHRC_FALLBACK="
# Dotfiles: Zsh fallback (odpala Zsh automatycznie, jesli chsh zawiodlo)
if [ -x \"$ZSH_PATH\" ] && [ \"\$SHELL\" != \"$ZSH_PATH\" ]; then
    export SHELL=\"$ZSH_PATH\"
    exec \"$ZSH_PATH\" -l
fi
"
                # Dodaj tylko jeśli jeszcze tego nie ma
                if ! grep -q "Dotfiles: Zsh fallback" "$HOME/.bashrc" 2>/dev/null; then
                    echo "$BASHRC_FALLBACK" >> "$HOME/.bashrc"
                    echo "Sukces: Dodano instrukcję przełączania na Zsh do ~/.bashrc."
                else
                    echo "Instrukcja przełączania już istnieje w ~/.bashrc."
                fi
            fi
        fi
    fi
fi
# 5. Konfiguracja dotfiles (Bare repo)
echo "==> Setting up dotfiles from source: $REPO_SRC..."
mkdir -p "$HOME/personal"
CFG_DIR="$HOME/personal/.cfg"

# Helper function dla polecenia git zarządzającego dotfiles
config() {
   git --git-dir="$CFG_DIR" --work-tree="$HOME" "$@"
}

if [ ! -d "$CFG_DIR" ]; then
    git clone --bare --no-hardlinks "$REPO_SRC" "$CFG_DIR"
fi

config config core.sparseCheckout true
config config status.showUntrackedFiles no

mkdir -p "$CFG_DIR/info"
cat << 'EOF' > "$CFG_DIR/info/sparse-checkout"
/*
!/README.md
!/setup.sh
!/test.sh
!/Dockerfile
EOF

# BEZPIECZNY CHECKOUT: Sprawdza, czy nadpisze pliki, robi backup i dopiero wtedy wgrywa
echo "==> Checking out dotfiles..."
if config checkout; then
  echo "Dotfiles checked out successfully."
else
  echo "Wykryto kolizje plików dotfiles. Tworzę kopię zapasową w ~/.dotfiles-backup..."
  mkdir -p "$HOME/.dotfiles-backup"
  
  # Wyciąganie plików, które blokują checkout i przenoszenie ich do backupu
  config checkout 2>&1 | grep -E "\s+" | awk {'print $1'} | while read -r file; do
      if [ -f "$HOME/$file" ] || [ -d "$HOME/$file" ]; then
          mkdir -p "$HOME/.dotfiles-backup/$(dirname "$file")"
          mv "$HOME/$file" "$HOME/.dotfiles-backup/$file"
          echo "Backed up: $file"
      fi
  done
  
  # Druga próba (teraz powinno pójść gładko)
  config checkout -f
fi

# 6. Dodanie aliasu 'config' do .zshrc
if ! grep -q "alias config=" "$HOME/.zshrc" 2>/dev/null; then
    echo "" >> "$HOME/.zshrc"
    echo "# Dotfiles bare repo alias" >> "$HOME/.zshrc"
    echo "alias config='git --git-dir=\$HOME/personal/.cfg/ --work-tree=\$HOME'" >> "$HOME/.zshrc"
fi

# 7. Safely configure Git include path
echo "==> Configuring Git include path..."
git config --global include.path "~/.gitconfig-common"

# 8. Zsh plugins & TPM
echo "==> Installing Zsh & Tmux plugins..."
ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

[ ! -d "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions" ] && git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions" || true
[ ! -d "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting" ] && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting" || true
[ ! -d "$HOME/.tmux/plugins/tpm" ] && git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm" || true

# 9. Dodanie wizualnego oznaczenia SSH w Tmux
echo "==> Configuring Tmux SSH status bar highlight..."
TMUX_CONF="$HOME/.tmux.conf"
touch "$TMUX_CONF" # Upewniamy się, że plik istnieje

if ! grep -q "SSH_CLIENT" "$TMUX_CONF" 2>/dev/null; then
    cat << 'EOF' >> "$TMUX_CONF"

# --- Zmiana wyglądu paska w przypadku sesji SSH ---
# Sprawdza czy istnieje zmienna SSH_CLIENT
if-shell 'test -n "$SSH_CLIENT"' \
    'set -g status-bg red ; set -g status-fg white ; set -g status-left "#[bg=colour22,fg=white,bold] 🚀 SSH: #H #[default] "'
EOF
    echo "Skonfigurowano czerwony pasek Tmux dla połączeń SSH."
else
    echo "Konfiguracja SSH w Tmux już istnieje."
fi

echo "=========================================="
echo " Installation completed successfully!"
echo "=========================================="
