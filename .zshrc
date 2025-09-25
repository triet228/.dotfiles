# ~/.zshrc

# ------------------------------------------------------------------------------
# ENVIRONMENT & EXPORTS
# ------------------------------------------------------------------------------

# Set default editor
export EDITOR=vim
export VISUAL=vim

# Add local binaries to the path
export PATH="$HOME/.local/bin:$PATH"

# Custom colors for eza/ls
export EZA_COLORS="di=1;36:fi=0:ex=1;32:*.kdbx=1;37:da=38;5;250"

# ------------------------------------------------------------------------------
# SHELL OPTIONS (setopt)
# ------------------------------------------------------------------------------

# Navigate directories by just typing their name
setopt autocd

# Allow comments in the interactive shell
setopt interactivecomments

# Make globbing (e.g. `ls *.txt`) case-insensitive
setopt nocaseglob

# Required for the prompt to display git info correctly
setopt PROMPT_SUBST

# ------------------------------------------------------------------------------
# HISTORY CONFIGURATION
# ------------------------------------------------------------------------------

HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt APPEND_HISTORY       # Append to history file
setopt INC_APPEND_HISTORY   # Add commands to history immediately
setopt SHARE_HISTORY        # Share history between all sessions
setopt HIST_IGNORE_ALL_DUPS # Remove older duplicate entries
setopt HIST_REDUCE_BLANKS   # Remove blank lines from history


# ------------------------------------------------------------------------------
# PROMPT CONFIGURATION
# ------------------------------------------------------------------------------

# Load version control system info and colors
autoload -Uz vcs_info colors && colors

# Function to run before every prompt
precmd() {
  # Get git info
  vcs_info

  # --- Conditional Prompt Logic ---
  # Set a character limit for the path length
  local path_len_threshold=20 

  # Check the length of the displayed path (%~)
  if [[ ${#${(%):-%~}} -gt $path_len_threshold ]]; then
    # If the path is LONG, use a two-line prompt
    PROMPT=$'%F{yellow}[%F{green}%n@%m %F{cyan}%~%F{yellow}]%f\n>> '
  else
    # If the path is SHORT, use a single-line prompt
    PROMPT=$'%F{yellow}[%F{green}%n@%m %F{cyan}%~%F{yellow}]%f$ '
  fi

  # Add blank line before prompt
  echo
}

# Format for the git branch info (e.g., "on main")
zstyle ':vcs_info:git:*' formats '%F{magenta}on %b%f'

# Right side of the prompt: git branch info
RPROMPT='${vcs_info_msg_0_}'


# ------------------------------------------------------------------------------
# PLUGINS & EXTERNAL TOOLS INITIALIZATION
# ------------------------------------------------------------------------------

# Load zsh-autosuggestions
if [[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# Load zsh-syntax-highlighting
if [[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# -- fzf (Fuzzy Finder) --
# Load fzf keybindings and completion
[[ -f /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh
[[ -f /usr/share/fzf/completion.zsh ]] && source /usr/share/fzf/completion.zsh

# Alt+C to cd into a directory starting from home
export FZF_ALT_C_COMMAND="find ~ -type d"

# Ctrl+H to find a file starting from home
fzf_file_from_home() {
  local orig_cmd="$FZF_CTRL_T_COMMAND"
  FZF_CTRL_T_COMMAND="find ~ -type f" fzf-file-widget
  FZF_CTRL_T_COMMAND="$orig_cmd"
}
zle -N fzf_file_from_home
bindkey '^H' fzf_file_from_home

# -- Other Tools --
eval "$(zoxide init zsh)"
eval "$(direnv hook zsh)"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/opt/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/opt/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# Load local/private configs if they exist
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# ------------------------------------------------------------------------------
# COMPLETION & KEYBINDINGS
# ------------------------------------------------------------------------------

# Initialize the tab completion system
autoload -Uz compinit
compinit

# Make tab completion case-insensitive
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Keybindings
bindkey '^F' complete-word      # Ctrl+F to complete word
bindkey '^I' autosuggest-accept # Tab to accept suggestion
setxkbmap -option caps:swapescape # Swap Caps Lock and Escape

# ------------------------------------------------------------------------------
# ALIASES
# ------------------------------------------------------------------------------

# Navigation & Listing
alias ll='eza -la --sort=ext --icons --group-directories-first --time-style=long-iso --git'
alias ls='eza -l --sort=ext --icons --group-directories-first --time-style=long-iso --git --no-permissions --no-user'
alias lss='eza --icons --tree --level=2 --group-directories-first'
alias lsss='eza --icons --tree --level=3 --group-directories-first'
alias lssss='eza --icons --tree --level=4 --group-directories-first'
alias lsssss='eza --icons --tree --level=5 --group-directories-first'
alias lssssss='eza --icons --tree --level=6 --group-directories-first'
alias lsssssss='eza --icons --tree --level=7 --group-directories-first'
alias lssssssss='eza --icons --tree --level=8 --group-directories-first'
alias lsssssssss='eza --icons --tree --level=9 --group-directories-first'
alias d='cd ~/Downloads'
alias p='cd ~/Projects/'
alias bin='cd ~/.local/bin'
alias h='z ~ && ll'
alias da='z ~/Data/ && ls'
alias c='z ~/Data/CLASSES && ls'

# System & Utilities
alias update='yay -Syu --noconfirm'
alias sleepp='slock & systemctl suspend'
alias math='qalc'
alias icat='kitty +kitten icat'

# File operations
alias cpd='cp -t ~/Downloads'
alias yy='pwd | tr -d "\n" | xclip -selection clipboard'

# ------------------------------------------------------------------------------
# FUNCTIONS
# ------------------------------------------------------------------------------

# General function to open a file with the default application
open() {
  xdg-open "$@" >/dev/null 2>&1 &
}

# Open lf and cd to the last directory on exit
lff() {
  local tmp="$(mktemp)"
  lf -last-dir-path="$tmp" "$@"
  if [[ -f "$tmp" ]]; then
    local dir="$(< "$tmp")"
    rm -f "$tmp"
    [[ -d "$dir" ]] && cd "$dir"
  fi
}

# Override 'cd' to use zoxide and then list directory contents
cd() {
  z "$@" && ls
}

# Copy contents of current directory to Downloads
cptd() {
  cp -r -- ./* ~/Downloads/
}

# Move contents of Downloads to current directory
mvfd() {
  mv ~/Downloads/* .
}

# Clean system caches and packages
clean() {
  yay -Scc --noconfirm
  yay -Yc --noconfirm
  sudo pacman -Rns $(pacman -Qtdq --quiet) --noconfirm
  sudo pacman -Scc --noconfirm
  sudo journalctl --vacuum-size=50M
  sudo paccache -rk1
  sudo rm -rf ~/Downloads/*
  sudo rm -rf ~/Pictures/*
  bash -O extglob -c 'rm -rf ~/.cache/!(keepassxc|Tectonic|mozilla)'
  sudo rm -rf /tmp/*
  git --git-dir=$HOME/.dotfiles/.git --work-tree=$HOME/.dotfiles pull
  clear
  neofetch
}

# If a command is not found, try to open it as a file
command_not_found_handler() {
  if [[ -f "$1" ]]; then
    xdg-open "$1"
  else
    echo "zsh: command not found: $1" >&2 # Send error to stderr
    return 127
  fi
}

# Print out cat at the start of shell
neofetch
