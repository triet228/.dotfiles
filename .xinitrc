command -v setxkbmap >/dev/null && setxkbmap -option caps:swapescape &
command -v sxhkd >/dev/null && sxhkd &
command -v kitty >/dev/null && kitty &
command -v github-desktop >/dev/null && github-desktop &
command -v firefox >/dev/null && firefox &
command -v slstatus >/dev/null && slstatus &
command -v keepassxc >/dev/null && keepassxc --allow-screencapture &
command -v xdotool >/dev/null && (xdotool search --sync --class KeePassXC >/dev/null; xdotool key --clearmodifiers alt+9 Return alt+1) &
command -v xset >/dev/null && xset -b &
command -v copyq >/dev/null && copyq &
exec dwm
