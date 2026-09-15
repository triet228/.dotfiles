#!/bin/sh

set -eu

repo=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

official_packages="
atool
base-devel
bat
bluez
bluez-utils
brightnessctl
copyq
curl
delta
direnv
dmenu
docker
dunst
eza
fastfetch
fd
file
firefox
fzf
git
ghostscript
github-cli
gzip
imagemagick
keepassxc
kitty
less
lf
libnotify
libqalculate
libx11
libxft
libxinerama
maim
man-db
man-pages
neovim
neofetch
nodejs-lts-krypton
noto-fonts
noto-fonts-cjk
noto-fonts-emoji
npm
ollama
openssh
pacman-contrib
pavucontrol
picom
pipewire
pipewire-alsa
pipewire-pulse
playerctl
polkit-gnome
poppler
python
python-vobject
ripgrep
rofi
rtkit
slock
sudo
sxhkd
tailscale
tar
tmux
trash-cli
ttf-dejavu
ttf-liberation
ttf-nerd-fonts-symbols-mono
unzip
vim
wireplumber
xclip
xdg-utils
xdg-user-dirs
xdotool
xorg-setxkbmap
xorg-xrandr
xorg-server
xorg-xinit
xorg-xset
zoxide
zsh
zsh-autosuggestions
zsh-syntax-highlighting
"

aur_packages="
dwm
find-cursor
gcalcli
github-desktop-bin
python-xlsx2csv
teams-for-linux
zoom
"

sudo pacman -S --needed --noconfirm $official_packages

if ! command -v yay >/dev/null 2>&1; then
    temporary=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$temporary/yay"
    (cd "$temporary/yay" && makepkg -si --noconfirm)
    rm -rf -- "$temporary"
fi

yay -S --needed --noconfirm $aur_packages

sudo install -Dm644 \
    "$repo/systemd/system/systemd-networkd-wait-online.service.d/override.conf" \
    /etc/systemd/system/systemd-networkd-wait-online.service.d/override.conf
sudo systemctl daemon-reload
sudo systemctl enable --now \
    bluetooth.service \
    docker.service \
    ollama.service \
    tailscaled.service
case " $(id -nG) " in
    *" docker "*) ;;
    *) sudo usermod -aG docker "$USER" ;;
esac

unfold_runtime_dir() {
    relative=$1
    source=$repo/$relative
    target=$HOME/$relative

    if [ -L "$target" ] && [ "$(readlink -f "$target")" = "$source" ]; then
        temporary=$(mktemp -d)
        cp -a "$source"/. "$temporary"/
        unlink "$target"
        mkdir -p "$target"
        cp -a "$temporary"/. "$target"/
        rm -rf -- "$temporary"
    fi
}

link_file() {
    relative=$1
    source=$repo/$relative
    target=$HOME/$relative

    mkdir -p "$(dirname -- "$target")"
    if [ -L "$target" ] && [ "$(readlink -f "$target")" = "$source" ]; then
        return
    fi
    if [ -f "$target" ] && cmp -s "$source" "$target"; then
        rm -- "$target"
    elif [ -e "$target" ] || [ -L "$target" ]; then
        printf 'Refusing to replace conflicting path: %s\n' "$target" >&2
        exit 1
    fi
    ln -s "$source" "$target"
}

link_dir() {
    relative=$1
    source=$repo/$relative
    target=$HOME/$relative

    mkdir -p "$(dirname -- "$target")"
    if [ -L "$target" ] && [ "$(readlink -f "$target")" = "$source" ]; then
        return
    fi
    if [ -e "$target" ] || [ -L "$target" ]; then
        printf 'Refusing to replace conflicting path: %s\n' "$target" >&2
        exit 1
    fi
    ln -s "$source" "$target"
}

# These locations contain application state, so only their tracked files should
# link into the repository.
unfold_runtime_dir .codex
unfold_runtime_dir .claude
unfold_runtime_dir .local/bin

for relative in \
    .codex/AGENTS.md \
    .claude/settings.json \
    .gitconfig \
    .local/bin/bluetooth \
    .local/bin/project \
    .ssh/config \
    .tmux.conf \
    .vimrc \
    .xinitrc \
    .zshrc
do
    link_file "$relative"
done

chmod 700 "$HOME/.ssh"
find "$HOME/.ssh" -maxdepth 1 -type f -exec chmod 600 {} +
find "$HOME/.ssh" -maxdepth 1 -type f \
    \( -name '*.pub' -o -name 'known_hosts' -o -name 'known_hosts.old' \) \
    -exec chmod 644 {} +

for relative in \
    .config/fastfetch \
    .config/kitty \
    .config/lf \
    .config/nvim \
    .config/sxhkd \
    .tmux
do
    link_dir "$relative"
done

xdg-user-dirs-update
mkdir -p "$HOME/.local/share/nvim/site/autoload"
curl -fLo "$HOME/.local/share/nvim/site/autoload/plug.vim" \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
nvim --headless '+PlugInstall --sync' +qa
if [ ! -x "$HOME/.local/share/nvim/mason/bin/pyright-langserver" ]; then
    nvim --headless '+MasonInstall pyright' '+sleep 30' +qa
fi

if [ -n "${DISPLAY:-}" ]; then
    pgrep -u "$USER" -x sxhkd >/dev/null 2>&1 && pkill -USR1 -x sxhkd || true
    pgrep -u "$USER" -x dunst >/dev/null 2>&1 || dunst &
    pgrep -u "$USER" -x picom >/dev/null 2>&1 || picom --daemon
fi

printf 'Arch dotfiles are installed. Restart dwm to load the session changes.\n'
