setxkbmap -option caps:swapescape &
sxhkd &
sudo systemctl start tailscaled &
kitty & 
firefox & 
slstatus &
keepassxc --allow-screencapture &
ferdium &
sudo systemctl restart tailscaled &
xset -b &
xrandr --output DP-0 --off --output DP-1 --off --output HDMI-0 --mode 1920x1080 --pos 0x0 --rotate normal --output DP-2 --off
exec dwm
