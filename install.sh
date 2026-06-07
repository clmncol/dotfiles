#!/bin/sh

# Exit immediately if a command exits with a non-zero status
set -e
# Exit on unset variables
set -u

# --- Configuration ---
REPO_URL="https://github.com/clmncol/dotfiles.git"
DOTFILES_DIR="${HOME}/.dotfiles"

# --- Formatting ---
setup_colors() {
    if [ -t 1 ]; then
        RED='\033[0;31m'
        GREEN='\033[0;32m'
        BLUE='\033[0;34m'
        YELLOW='\033[1;33m'
        NC='\033[0m' # No Color
    else
        RED=''
        GREEN=''
        BLUE=''
        YELLOW=''
        NC=''
    fi
}

info() { printf "%bℹ%b %s\n" "${BLUE}" "${NC}" "$*"; }
success() { printf "%b✓%b %s\n" "${GREEN}" "${NC}" "$*"; }
warn() { printf "%b⚠%b %s\n" "${YELLOW}" "${NC}" "$*"; }
error() { printf "%b✗%b %s\n" "${RED}" "${NC}" "$*" >&2; }
fatal() { error "$*"; exit 1; }

# --- Dependencies ---
install_package() {
    package=$1
    info "Attempting to install $package..."
    if command -v brew >/dev/null 2>&1; then
        brew install "$package"
    elif command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update && sudo apt-get install -y "$package"
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y "$package"
    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -S --noconfirm "$package"
    elif command -v zypper >/dev/null 2>&1; then
        sudo zypper install -y "$package"
    else
        fatal "No supported package manager found. Please install $package manually."
    fi
}

check_deps() {
    info "Checking dependencies..."
    for dep in git curl bash fzf; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            warn "$dep is not installed."
            install_package "$dep"
        fi
    done
    
    if ! command -v starship >/dev/null 2>&1; then
        warn "starship is not installed."
        info "Installing starship..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y || fatal "Failed to install starship."
    fi
    
    success "All dependencies met."
}

# --- Clone Repository ---
clone_dotfiles() {
    if [ -d "$DOTFILES_DIR" ]; then
        warn "Dotfiles directory already exists at $DOTFILES_DIR"
        info "Updating existing repository..."
        git -C "$DOTFILES_DIR" pull --rebase origin main || fatal "Failed to update dotfiles."
    else
        info "Cloning dotfiles to $DOTFILES_DIR..."
        git clone "$REPO_URL" "$DOTFILES_DIR" || fatal "Failed to clone dotfiles."
    fi
    success "Repository ready."
}

# --- Setup / Symlink ---
link_file() {
    src="$1"
    dest="$2"
    backup_dir="$3"
    
    if [ -L "$dest" ]; then
        current_link=$(readlink "$dest" 2>/dev/null || true)
        if [ "$current_link" = "$src" ]; then
            success "Already linked: $dest"
            return
        fi
    fi
    
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        warn "File exists, backing up: $dest -> $backup_dir"
        mkdir -p "$backup_dir"
        mv "$dest" "$backup_dir/"
    fi
    
    mkdir -p "$(dirname "$dest")"
    ln -s "$src" "$dest"
    success "Linked: $dest"
}

setup_symlinks() {
    info "Setting up symlinks..."
    
    backup_dir="${HOME}/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
    
    # Standard tools
    link_file "$DOTFILES_DIR/bashrc" "${HOME}/.bashrc" "$backup_dir"
    link_file "$DOTFILES_DIR/starship.toml" "${HOME}/.config/starship.toml" "$backup_dir"
    link_file "$DOTFILES_DIR/ghostty.config" "${HOME}/.config/ghostty/config" "$backup_dir"
    link_file "$DOTFILES_DIR/nvim" "${HOME}/.config/nvim" "$backup_dir"
    
    # VS Code setup
    os_name=$(uname -s)
    if [ "$os_name" = "Darwin" ]; then
        vscode_dir="${HOME}/Library/Application Support/Code/User"
    else
        vscode_dir="${HOME}/.config/Code/User"
    fi
    
    # Safely link individual files in vscode directory to avoid polluting repo
    # with global storage or workspace state.
    for file in "$DOTFILES_DIR/vscode/"*; do
        [ -e "$file" ] || continue
        filename=$(basename "$file")
        link_file "$file" "$vscode_dir/$filename" "$backup_dir"
    done
}

# --- Uninstall ---
remove_link() {
    dest="$1"
    if [ -L "$dest" ]; then
        rm "$dest"
        success "Removed symlink: $dest"
    elif [ -e "$dest" ]; then
        warn "Skipped $dest (it is a regular file, not a symlink created by this script)"
    fi
}

uninstall() {
    info "Uninstalling dotfiles..."
    
    remove_link "${HOME}/.bashrc"
    remove_link "${HOME}/.config/starship.toml"
    remove_link "${HOME}/.config/ghostty/config"
    remove_link "${HOME}/.config/nvim"
    
    os_name=$(uname -s)
    if [ "$os_name" = "Darwin" ]; then
        vscode_dir="${HOME}/Library/Application Support/Code/User"
    else
        vscode_dir="${HOME}/.config/Code/User"
    fi
    
    remove_link "$vscode_dir/settings.json"
    remove_link "$vscode_dir/keybindings.json"
    
    if [ -d "$DOTFILES_DIR" ]; then
        rm -rf "$DOTFILES_DIR"
        success "Removed repository at $DOTFILES_DIR"
    fi
    
    success "Uninstallation complete! (Note: Backup directories ~/.dotfiles_backup_* were kept intact)"
}

main() {
    setup_colors
    
    if [ "${1:-}" = "uninstall" ]; then
        uninstall
        exit 0
    fi
    
    info "Starting dotfiles installation..."
    
    check_deps
    clone_dotfiles
    setup_symlinks
    
    success "Installation complete! 🎉"
    info "Please restart your terminal or run: source ~/.bashrc"
}

main "$@"
