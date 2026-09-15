#!/bin/sh

run_once() {
    command -v "$1" >/dev/null 2>&1 || return
    pgrep -u "$USER" -x "$1" >/dev/null 2>&1 || "$@" &
}

command -v setxkbmap >/dev/null 2>&1 && setxkbmap -option caps:swapescape
command -v xset >/dev/null 2>&1 && xset b off
command -v xdg-user-dirs-update >/dev/null 2>&1 && xdg-user-dirs-update
command -v dbus-update-activation-environment >/dev/null 2>&1 && \
    dbus-update-activation-environment --systemd DISPLAY XAUTHORITY

run_once sxhkd
run_once dunst
run_once picom --daemon
run_once copyq
run_once keepassxc --allow-screencapture
run_once kitty
run_once github-desktop
run_once firefox

if command -v xdotool >/dev/null 2>&1; then
    (xdotool search --sync --class '^GitHub Desktop$' >/dev/null && \
        sleep 1 && xdotool key --clearmodifiers alt+1) &
fi

if [ -x /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 ] && \
    ! pgrep -u "$USER" -f '/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1$' >/dev/null 2>&1; then
    /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
fi

if command -v xdotool >/dev/null 2>&1 && pgrep -u "$USER" -x keepassxc >/dev/null 2>&1; then
    (xdotool search --sync --class KeePassXC >/dev/null && \
        xdotool key --clearmodifiers alt+9 Return alt+1) &
fi

exec dwm
