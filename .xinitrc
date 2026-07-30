command -v setxkbmap >/dev/null && setxkbmap -option caps:swapescape &
command -v sxhkd >/dev/null && sxhkd &
command -v kitty >/dev/null && kitty &
command -v codex-desktop >/dev/null && codex-desktop &
command -v firefox >/dev/null && firefox &
command -v slstatus >/dev/null && slstatus &
command -v keepassxc >/dev/null && keepassxc --allow-screencapture &
command -v xset >/dev/null && xset -b &
exec dwm
