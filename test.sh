#!/usr/bin/env bash

set -e

echo "=========================================="
echo " Running Dotfiles & Workstation Test Suite"
echo "=========================================="

PASSED=0
FAILED=0

assert_installed() {
    local cmd=$1
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "[PASS] Binary '$cmd' is installed."
        PASSED=$((PASSED + 1))
    else
        echo "[FAIL] Binary '$cmd' is NOT installed!"
        FAILED=$((FAILED + 1))
    fi
}

assert_dir_exists() {
    local dir=$1
    local label=$2
    if [ -d "$dir" ]; then
        echo "[PASS] $label directory exists ($dir)."
        PASSED=$((PASSED + 1))
    else
        echo "[FAIL] $label directory does NOT exist ($dir)!"
        FAILED=$((FAILED + 1))
    fi
}

assert_file_contains() {
    local file=$1
    local pattern=$2
    local label=$3
    if [ -f "$file" ] && grep -q "$pattern" "$file"; then
        echo "[PASS] $label found in $file."
        PASSED=$((PASSED + 1))
    else
        echo "[FAIL] $label NOT found in $file!"
        FAILED=$((FAILED + 1))
    fi
}

# 1. Test required binaries
echo ""
echo "--> Testing required binaries..."
assert_installed zsh
assert_installed tmux
assert_installed feh
assert_installed curl
assert_installed git

# 2. Test installation directories & repositories
echo ""
echo "--> Testing installation directories..."
assert_dir_exists "$HOME/.oh-my-zsh" "Oh My Zsh"
assert_dir_exists "$HOME/personal/.cfg" "Dotfiles bare repository"
assert_dir_exists "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" "Zsh Autosuggestions plugin"
assert_dir_exists "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" "Zsh Syntax Highlighting plugin"
assert_dir_exists "$HOME/.tmux/plugins/tpm" "Tmux Plugin Manager (TPM)"

# 3. Test configurations
echo ""
echo "--> Testing configuration settings..."
assert_file_contains "$HOME/.zshrc" "alias config=" "Alias 'config'"

GIT_INCLUDE=$(git config --global --get include.path || true)
if [ "$GIT_INCLUDE" = "~/.gitconfig-common" ]; then
    echo "[PASS] Git include path is set to '~/.gitconfig-common'."
    PASSED=$((PASSED + 1))
else
    echo "[FAIL] Git include path is '$GIT_INCLUDE' (expected '~/.gitconfig-common')!"
    FAILED=$((FAILED + 1))
fi

echo ""
echo "=========================================="
echo " Test Summary: $PASSED Passed, $FAILED Failed"
echo "=========================================="

if [ "$FAILED" -gt 0 ]; then
    exit 1
fi