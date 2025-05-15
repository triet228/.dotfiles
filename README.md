# What are dotfiles?
Dotfiles are files start with dot (example: .zshrc). 


# Why dotfiles?
Dotfiles are used to change configuration of program. For example, my original terminal has no colors, just black and white. To change this to colorful terminal, I go to my dotfiles (.zshrc) and add a few lines to add colors. There is no point in a centralized folder for dotfiles if I only run one machine. However, I run multiple machines and I want to sync the configuration across my machines. Therefore, having this dotfiles centralized into a git repo is more conveient to manage. I could've used syncthing to sync this dotfiles too but a git repo offer a very good backup of previous version just in case something happen and I lost my dotfiles.


# How to use this repo
I manage my dotfiles with stow. Stow is a program that ultilize symlink. Symlink links files between different directories so that if one file is changed, the linked file is also changed. Instead of manually write symlink for all dotfiles, stow automatically does it with ```stow . -t ~/``` This command symlinks all the dotfiles in this repo to my home directory instead of me doing symlink one by one.


Go to home directory
```
cd ~
```


Clone the repo
```
git clone https://github.com/triet228/.dotfiles.git
```


Go inside the repo
```
cd ~/.dotfiles
```


Run command stow
```
stow . -t ~/
```


Note: You likely get error message because stow does NOT overwrite existing dotfiles so you might need to go delete all the dotfiles yourself before being able to use stow. Proceed with caution and take it at your own risk.



