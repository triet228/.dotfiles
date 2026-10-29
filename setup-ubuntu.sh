#!/bin/sh

set -eu

repo=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
backup=$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)

packages="
atool
bat
brightnessctl
curl
direnv
eza
build-essential
fd-find
file
fish
fzf
gh
ghostscript
git
git-delta
imagemagick
kitty
lf
libsecret-1-dev
libsecret-tools
pkg-config
nodejs
npm
poppler-utils
ripgrep
tmux
trash-cli
unzip
vim
xclip
zoxide
zsh
zsh-autosuggestions
zsh-syntax-highlighting
"

if [ "${SKIP_APT:-0}" != 1 ]; then
    sudo apt-get update
    available=
    for package in $packages; do
        if apt-cache show "$package" >/dev/null 2>&1; then
            available="$available $package"
        else
            printf 'Not in apt on this release, skipping: %s\n' "$package" >&2
        fi
    done
    sudo apt-get install -y $available
fi

# Ubuntu names these binaries differently from Arch.
mkdir -p "$HOME/.local/bin"
command -v fd >/dev/null 2>&1 || ! command -v fdfind >/dev/null 2>&1 || \
    ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
command -v bat >/dev/null 2>&1 || ! command -v batcat >/dev/null 2>&1 || \
    ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"

# fastfetch is not in the Ubuntu 24.04 archive, so use the upstream package.
if ! command -v fastfetch >/dev/null 2>&1; then
    case $(uname -m) in
        aarch64) fastfetch_arch=aarch64 ;;
        *) fastfetch_arch=amd64 ;;
    esac
    temporary=$(mktemp -d)
    curl -fL "https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-$fastfetch_arch.deb" \
        -o "$temporary/fastfetch.deb"
    sudo apt-get install -y "$temporary/fastfetch.deb"
    rm -rf -- "$temporary"
fi

# Git's libsecret credential helper ships only as source on Ubuntu.
if [ ! -x /usr/lib/git-core/git-credential-libsecret ]; then
    temporary=$(mktemp -d)
    cp -r /usr/share/doc/git/contrib/credential/libsecret/. "$temporary"
    make -C "$temporary"
    sudo install -m755 "$temporary/git-credential-libsecret" /usr/lib/git-core/
    rm -rf -- "$temporary"
fi

# The Neovim config uses vim.lsp.config, which needs Neovim 0.11 or newer.
# Ubuntu 24.04 ships 0.9, so install the upstream release when it is older.
nvim_ok=0
if command -v nvim >/dev/null 2>&1; then
    nvim --headless '+lua if vim.lsp.config then vim.cmd("cquit 0") else vim.cmd("cquit 1") end' \
        >/dev/null 2>&1 && nvim_ok=1
fi
if [ "$nvim_ok" != 1 ]; then
    case $(uname -m) in
        aarch64) nvim_arch=arm64 ;;
        *) nvim_arch=x86_64 ;;
    esac
    temporary=$(mktemp -d)
    curl -fL "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-$nvim_arch.tar.gz" \
        -o "$temporary/nvim.tar.gz"
    rm -rf "$HOME/.local/nvim"
    mkdir -p "$HOME/.local/nvim"
    tar -xzf "$temporary/nvim.tar.gz" -C "$HOME/.local/nvim" --strip-components=1
    ln -sf "$HOME/.local/nvim/bin/nvim" "$HOME/.local/bin/nvim"
    rm -rf -- "$temporary"
fi

# Conflicting files are moved into a timestamped backup, not deleted.
move_aside() {
    target=$1
    mkdir -p "$backup/$(dirname -- "${target#"$HOME"/}")"
    mv -- "$target" "$backup/${target#"$HOME"/}"
    printf 'Backed up %s to %s\n' "$target" "$backup" >&2
}

link_path() {
    relative=$1
    source=$repo/$relative
    target=$HOME/$relative

    mkdir -p "$(dirname -- "$target")"
    if [ -L "$target" ] && [ "$(readlink -f "$target")" = "$source" ]; then
        return
    fi
    if [ -e "$target" ] || [ -L "$target" ]; then
        if [ -f "$target" ] && cmp -s "$source" "$target"; then
            rm -- "$target"
        else
            move_aside "$target"
        fi
    fi
    ln -s "$source" "$target"
}

for relative in \
    .codex/AGENTS.md \
    .claude/settings.json \
    .config/fish/config.fish \
    .gitconfig \
    .local/bin/project \
    .ssh/config \
    .tmux.conf \
    .vimrc \
    .zshrc
do
    link_path "$relative"
done

for relative in \
    .config/fastfetch \
    .config/kitty \
    .config/lf \
    .config/nvim \
    .tmux
do
    link_path "$relative"
done

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
chmod 600 "$repo/.ssh/config"

mkdir -p "$HOME/.local/share/nvim/site/autoload"
curl -fLo "$HOME/.local/share/nvim/site/autoload/plug.vim" \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
# The gitconfig rewrites GitHub HTTPS URLs to SSH, which fails without a key,
# and these plugins are public.
export PATH="$HOME/.local/bin:$PATH"
GIT_CONFIG_GLOBAL=/dev/null nvim --headless '+PlugInstall --sync' +qa
if [ ! -x "$HOME/.local/share/nvim/mason/bin/pyright-langserver" ]; then
    GIT_CONFIG_GLOBAL=/dev/null nvim --headless '+MasonInstall pyright' '+sleep 40' +qa
fi

printf 'Ubuntu dotfiles are installed. Desktop files (.xinitrc, sxhkd, dwm) are Arch/X11 only and were skipped.\n'
