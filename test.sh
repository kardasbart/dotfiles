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

assert_file_exists() {
    local file=$1
    local label=$2
    if [ -f "$file" ]; then
        echo "[PASS] $label file exists ($file)."
        PASSED=$((PASSED + 1))
    else
        echo "[FAIL] $label file does NOT exist ($file)!"
        FAILED=$((FAILED + 1))
    fi
}

assert_symlink_target() {
    local link=$1
    local expected_target=$2
    local label=$3
    if [ -L "$link" ] && [ "$(readlink "$link")" = "$expected_target" ]; then
        echo "[PASS] Symlink '$label' correctly points to $expected_target."
        PASSED=$((PASSED + 1))
    else
        echo "[FAIL] Symlink '$label' ($link) does NOT point to $expected_target!"
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

assert_file_not_exists() {
    local file=$1
    local label=$2
    if [ ! -e "$file" ]; then
        echo "[PASS] $label is correctly absent from $HOME."
        PASSED=$((PASSED + 1))
    else
        echo "[FAIL] $label unexpectedly exists in $HOME (sparse-checkout failed)!"
        FAILED=$((FAILED + 1))
    fi
}

# 1. Test binaries
echo ""
echo "--> Testing required binaries..."
assert_installed zsh
assert_installed tmux
assert_installed feh
assert_installed curl
assert_installed git
assert_installed mpv

# 2. Test directories
echo ""
echo "--> Testing installation directories..."
assert_dir_exists "$HOME/.oh-my-zsh" "Oh My Zsh"
assert_dir_exists "$HOME/personal/.cfg" "Dotfiles bare repository"
assert_dir_exists "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" "Zsh Autosuggestions plugin"
assert_dir_exists "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" "Zsh Syntax Highlighting plugin"
assert_dir_exists "$HOME/.tmux/plugins/tpm" "Tmux Plugin Manager (TPM)"

# 3. Test symlinks & user configuration files
echo ""
echo "--> Testing executable symlinks and config files..."
assert_symlink_target "$HOME/.local/bin/img" "/usr/bin/feh" "img executable symlink"
assert_symlink_target "$HOME/.local/bin/imgf" "/usr/bin/feh" "imgf executable symlink"
assert_file_exists "$HOME/.config/feh/themes" "feh themes config"
assert_file_exists "$HOME/.config/mpv/input.conf" "mpv input.conf"
assert_file_exists "$HOME/.config/mpv/mpv.conf" "mpv mpv.conf"

# 4. Test configurations & sparse-checkout exclusion rules
echo ""
echo "--> Testing configuration settings & sparse-checkout..."
assert_file_contains "$HOME/.zshrc" "alias config=" "Alias 'config'"

# Verify repository-only files are excluded from $HOME by sparse-checkout
assert_file_not_exists "$HOME/README.md" "README.md"
assert_file_not_exists "$HOME/setup.sh" "setup.sh"
assert_file_not_exists "$HOME/test.sh" "test.sh"
assert_file_not_exists "$HOME/Dockerfile" "Dockerfile"

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