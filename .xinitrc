setxkbmap -option caps:swapescape &
xcape -e 'Control_L=F2' &
sxhkd &
autorandr --change &
sudo systemctl start tailscaled &
kitty & 
firefox & 
slstatus &
keepassxc &
ferdium &
sudo systemctl restart tailscaled &
exec dwm
