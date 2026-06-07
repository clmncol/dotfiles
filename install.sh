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
    for dep in git curl bash fzf neovim bat btop ripgrep fd-find make jq gpg; do
        # Determine the binary name to check against
        cmd="$dep"
        if [ "$dep" = "neovim" ]; then cmd="nvim"; fi
        if [ "$dep" = "ripgrep" ]; then cmd="rg"; fi
        if [ "$dep" = "fd-find" ]; then
            if command -v fdfind >/dev/null 2>&1; then cmd="fdfind"; else cmd="fd"; fi
        fi
        
        if ! command -v "$cmd" >/dev/null 2>&1; then
            warn "$cmd is not installed."
            
            # Map for package managers
            pkg="$dep"
            if [ "$dep" = "fd-find" ] && command -v apt-get >/dev/null 2>&1; then pkg="fd-find"; fi
            if [ "$dep" = "fd-find" ] && ! command -v apt-get >/dev/null 2>&1; then pkg="fd-find"; fi # Fedora uses fd-find now too. Wait, let's just make sure.
            if [ "$dep" = "fd-find" ] && command -v dnf >/dev/null 2>&1; then pkg="fd-find"; fi
            if [ "$dep" = "fd-find" ] && command -v brew >/dev/null 2>&1; then pkg="fd"; fi
            if [ "$dep" = "fd-find" ] && command -v pacman >/dev/null 2>&1; then pkg="fd"; fi
            
            if [ "$dep" = "gpg" ] && command -v apt-get >/dev/null 2>&1; then pkg="gnupg"; fi
            if [ "$dep" = "gpg" ] && command -v brew >/dev/null 2>&1; then pkg="gnupg"; fi
            if [ "$dep" = "gpg" ] && command -v dnf >/dev/null 2>&1; then pkg="gnupg2"; fi
            
            install_package "$pkg"
        fi
    done
    
    # Setup Mise and Dev Tools
    if ! command -v mise >/dev/null 2>&1; then
        info "Installing mise (dev tools manager)..."
        curl https://mise.run | sh || warn "Failed to install mise."
        export PATH="$HOME/.local/bin:$PATH"
    fi
    
    if command -v mise >/dev/null 2>&1; then
        info "Installing Node.js (npm) and Go via mise..."
        mise use --global node@lts go@latest || warn "Failed to setup node/go via mise."
    fi
    
    if ! command -v cargo >/dev/null 2>&1; then
        warn "cargo is not installed."
        info "Installing Rust toolchain (rustup)..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y || warn "Failed to install Rust/cargo."
        # Attempt to source it so subsequent steps have it if needed
        if [ -f "$HOME/.cargo/env" ]; then
            . "$HOME/.cargo/env"
        fi
    fi
    
    if ! command -v glow >/dev/null 2>&1; then
        warn "glow is not installed."
        info "Attempting to install glow via go..."
        if command -v mise >/dev/null 2>&1; then
            mise exec -- go install github.com/charmbracelet/glow/v2@latest || warn "Failed to install glow via mise go."
        elif command -v go >/dev/null 2>&1; then
            go install github.com/charmbracelet/glow/v2@latest || warn "Failed to install glow via go."
        else
            warn "Go is not available. You may need to install glow manually."
        fi
    fi
    
    if ! command -v ghostty >/dev/null 2>&1; then
        warn "ghostty is not installed."
        info "Attempting to install ghostty..."
        os_name=$(uname -s)
        if [ "$os_name" = "Darwin" ] && command -v brew >/dev/null 2>&1; then
            brew install --cask ghostty || warn "Failed to install ghostty via brew."
        elif command -v dnf >/dev/null 2>&1; then
            if ! dnf copr enable -y scottames/ghostty >/dev/null 2>&1; then
                sudo dnf install -y 'dnf-command(copr)' || warn "Failed to install dnf-command(copr)."
            fi
            sudo dnf copr enable -y scottames/ghostty && sudo dnf install -y ghostty || warn "Failed to install ghostty via dnf copr."
        else
            install_package "ghostty" || warn "Could not install ghostty via package manager."
        fi
    fi
    
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
        warn "Dotfiles directory already exists at $DOTFILES_DIR. Removing for a fresh install..."
        rm -rf "$DOTFILES_DIR"
    fi
    info "Cloning dotfiles to $DOTFILES_DIR..."
    git clone "$REPO_URL" "$DOTFILES_DIR" || fatal "Failed to clone dotfiles."
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
    
    # VS Code setup and macOS Bash Profile setup
    os_name=$(uname -s)
    if [ "$os_name" = "Darwin" ]; then
        # On macOS, login shells use .bash_profile, not .bashrc by default
        if [ -f "${HOME}/.bash_profile" ] && ! grep -q "source ~/.bashrc" "${HOME}/.bash_profile" 2>/dev/null; then
             echo -e "\n[ -r ~/.bashrc ] && source ~/.bashrc" >> "${HOME}/.bash_profile"
             success "Added .bashrc source to .bash_profile for macOS"
        elif [ ! -f "${HOME}/.bash_profile" ]; then
             echo "[ -r ~/.bashrc ] && source ~/.bashrc" > "${HOME}/.bash_profile"
             success "Created .bash_profile to source .bashrc for macOS"
        fi
        
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
