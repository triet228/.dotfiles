
# ~/.zshrc

# Switch caps and escape key
setxkbmap -option caps:swapescape

# Only auto-start tmux if we're on a local terminal (not SSH)
if [ -z "$TMUX" ] && [ -z "$SSH_CONNECTION" ]; then
  tmux attach-session -t default || tmux new -s default
fi

# Load colors
autoload -Uz colors && colors

# Set colored prompt
PROMPT='%F{yellow}[%F{green}%n@%m %F{cyan}%~%F{yellow}]%f$ '

# History settings
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

# Update history in real-time
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS

# Plugins

# Show ghost suggestion
if [[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# Highlight command line colorful
if [[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Load key binding for fzf search
if [[ -f /usr/share/fzf/key-bindings.zsh ]]; then
    source /usr/share/fzf/key-bindings.zsh
fi

# Load fzf search completion
if [[ -f /usr/share/fzf/completion.zsh ]]; then
    source /usr/share/fzf/completion.zsh
fi

# New binding: ctrl-h to search from home
fzf_file_from_home() {
  local orig_cmd="$FZF_CTRL_T_COMMAND"
  FZF_CTRL_T_COMMAND="find ~ -type f" fzf-file-widget
  FZF_CTRL_T_COMMAND="$orig_cmd"
}
zle -N fzf_file_from_home
bindkey '^H' fzf_file_from_home

# Alt C to cd to folder from home directory
export FZF_ALT_C_COMMAND="find ~ -type d"

# Smart tab completion
autoload -Uz compinit
compinit

# Ctrl F to complete
bindkey '^F' complete-word

# Tab to accep ghost suggestion
bindkey '^I' autosuggest-accept

# Default editor
export EDITOR=vim
export VISUAL=vim

# Extend PATH
export PATH="$HOME/.local/bin:$PATH"

# Overwrite color for ls
export EZA_COLORS="di=1;36:fi=0:ex=1;32:*.kdbx=1;37:da=38;5;250"


# Aliases
alias ls='eza -l --icons --group-directories-first --time-style=long-iso --git --no-permissions --no-user'
alias ll='eza -la --icons --group-directories-first --time-style=long-iso --git'
alias lss='eza --icons --tree --level=2 --group-directories-first'
alias d='cd ~/Downloads'
alias bin='cd ~/.local/bin'
alias da='z ~/Data/ && ls'
alias c='z ~/Data/CLASSES && ls'
alias yy='pwd | tr -d "\n" | xclip -selection clipboard'
alias h='z ~ && ll'
alias p='cd ~/Projects/'
alias sleepp='slock & systemctl suspend'

# Options

# cd by just typing directory name
setopt autocd

# Make globbing (like cd, ls) case insensitive
setopt nocaseglob

# Make TAB completion case insensitive too
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# allow comments in the shell
setopt interactivecomments

# Load local configs
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# zoxide initialization
eval "$(zoxide init zsh)"
eval "$(direnv hook zsh)"

# Functions

# General function to open file
open() {
  xdg-open "$@" >/dev/null 2>&1 &
}

# Open last directory in lf
lff() {
    tmp="$(mktemp)"
    lf -last-dir-path="$tmp" "$@"
    if [[ -f "$tmp" ]]; then
        dir="$(< "$tmp")"
        rm -f "$tmp"
        [[ -d "$dir" ]] && cd "$dir"
    fi
}

# Open file if it exists
command_not_found_handler() {
    if [[ -f "$1" ]]; then
        xdg-open "$1"
    else
        echo "zsh: command not found: $1"
    fi
}

# Auto tree after cd
cd() {
    z "$@" && lss
}

# Blank line before prompt
precmd() { echo }

# Copy to Downloads folder
cptd() {
  cp -r -- ./* ~/Downloads/
}

# Move from Downloads folder
mvfd() {
  mv ~/Downloads/* .
}

# Clean system 
clean() {
  yay -Scc --noconfirm
  yay -Yc --noconfirm
  sudo pacman -Rns $(pacman -Qtdq --quiet) --noconfirm
  sudo pacman -Scc --noconfirm
  sudo journalctl --vacuum-size=50M
  sudo paccache -rk1
  sudo rm -rf ~/Downloads/*
  sudo rm -rf ~/Pictures/*
  bash -O extglob -c 'rm -rf ~/.cache/!(keepassxc|Tectonic)'
  sudo rm -rf /tmp/*
  clear
  neofetch
}


# Print out cat
neofetch



