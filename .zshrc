# History Control
HISTCONTROL=ignoredups:ignorespace
HISTSIZE=100000
HISTFILESIZE=2000000

# Only enable in bash terminals
[ "$BASH_VERSION" ] && shopt -s histappend

# Add Golang to PATH
# export PATH=$PATH:/usr/local/go/bin:~/go/bin
export EDITOR="vim"

# configure `time` format for debugging
if [[ `uname` == Darwin ]]; then
	MAX_MEMORY_UNITS=KB
else
	MAX_MEMORY_UNITS=MB
fi

TIMEFMT=$'\n'\
'user     %U'$'\n'\
'system   %S'$'\n'\
'cpu      %P'$'\n'\
'total    %*E'$'\n'\
'avg shared (code):          %X KB'$'\n'\
'avg unshared (data/stack):  %D KB'$'\n'\
'total (sum):                %K KB'$'\n'\
'max memory:                 %M '$MAX_MEMORY_UNITS''$'\n'\
'page faults from disk:      %F'$'\n'\
'other page faults:          %R'

# Identify what type of system for ls color output
# Darwin or Linux
if [[ "$(uname -s)" == "Darwin" ]]; then
  alias ls='ls -G'
else
  alias ls='ls --color=auto'
fi

# Dynamically identify rc file for editing
# Fallback to bashrc as the default
if [ "$ZSH_VERSION" ]; then
  export RC=".zshrc"
else
  export RC=".bashrc"
fi

# Run alias commands as sudo
alias sudo='sudo '

# Modify bash profile
alias rc='"${EDITOR}" ~/${RC} && source ~/${RC}'

# Basic aliases
alias :q='exit'
alias ll='ls -alF'
alias rm='rm -i'
alias clr='clear'
alias cls='clear'
alias grep='grep --color=auto'
alias mkdir='mkdir -pv'

# Always list directory contents upon 'cd'
cd() { builtin cd "$@"; ll; }

# Git aliases
alias push='git push origin '
alias pull='git pull origin '

# Network aliases
alias myip='curl ipinfo.io'
alias cons='lsof -i'
alias ports='sudo lsof -i | grep LISTEN'
alias cpups='ps wwaxr -o pid,stat,%cpu,time,command | head -10'
alias memps='ps wwaxm -o pid,stat,vsize,rss,time,command | head -10'
alias netuse="ps -o uid,pid,command -p $(lsof -ti | tr '\n' ' ') 2>/dev/null"

# Show $PATH in readable view
alias path='echo -e ${PATH//:/\\n}'

# Open AnyConnect VPN UI and background the process
# Since we are backgrounding just send all the std to /dev/null
# alias vpn='sudo bash -c "/opt/cisco/anyconnect/bin/vpnui 2>/dev/null &"'

# Folders Shortcuts
[ -d ~/Dropbox ]   && alias dr='cd ~/Dropbox'
[ -d ~/Downloads ] && alias dl='cd ~/Downloads'
[ -d ~/Desktop ]   && alias dt='cd ~/Desktop'
[ -d ~/Projects ]  && alias pj='cd ~/Projects'
[ -d ~/Tools ]     && alias tl='cd ~/Tools'

# E.g:
#   ccd   -> cd ../
#   ccd 2 -> cd ../../
#   ccd 3 -> cd ../../../
ccd() {
  local count=${1:-1}
  local cpath=""
  for i in $( seq 1 ${count} ); do
    cpath="${cpath}../"
  done
  cd "$cpath"
}

# Update bashrc by pulling most recent Gist file
# Fallback to bashrc as the default
update_rc() {
  local rc_file
  if [ "$ZSH_VERSION" ]; then
    rc_file="$HOME/.zshrc"
  else
    rc_file="$HOME/.bashrc"
  fi
  curl -o "$rc_file" https://gist.githubusercontent.com/0xZDH/0402f8659f9cb0ca60bd2d97f1a63657/raw
  source "$rc_file"
}

# Install starship prompt
if ! command -v starship > /dev/null 2>&1; then
  if which wget > /dev/null; then
    echo "Downloading Starship via wget"
    wget https://starship.rs/install.sh
  elif which curl >/dev/null ; then
    echo "Downloading Starship via curl"
    curl -sS -O https://starship.rs/install.sh
  else
    echo "Cannot download Starship. Exiting"
    exit 1
  fi
  sh ./install.sh
  rm ./install.sh
fi

# == ZSH Antidote handler ==

# Define config folder
export ZDOTDIR=~/.config/zsh

# Download plugin manager if we don't have it
if ! [[ -e $ZDOTDIR/antidote ]]; then
  git clone --depth=1 https://github.com/mattmc3/antidote.git ${ZDOTDIR:-~}/antidote
fi

# Make plugin folder names pretty
zstyle ':antidote:bundle' use-friendly-names 'yes'

# Source and load plugins found in ${ZDOTDIR}/.zsh_plugins.txt
source ${ZDOTDIR:-~}/antidote/antidote.zsh

# Install fzf binary if not found
if ! [[ -e "$(antidote home)/junegunn/fzf/bin/fzf" ]]; then
  antidote load
  "$(antidote home)/junegunn/fzf/install" --bin
fi

# Enable case insensitive tab-completion
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
autoload -Uz compinit && compinit

# Load the plugins
antidote load

# Allows zsh-vi to yank to clipboard
zvm_vi_yank () {
  zvm_yank
  printf %s "${CUTBUFFER}" | xclip -sel c
  zvm_exit_visual_mode
}

# Restore FZF Key bindings
zvm_after_init() {
  source "$(antidote home)/junegunn/fzf/shell/completion.zsh"
  source "$(antidote home)/junegunn/fzf/shell/key-bindings.zsh"
}

export FZF_CTRL_R_OPTS="
  --preview 'echo {}' --preview-window down:3:hidden:wrap
  --bind 'ctrl-/:toggle-preview'
  --bind 'ctrl-y:execute-silent(echo -n {2..} | xclip -sel c)+abort'
  --height 60%
  --color header:italic
  --header 'CTRL-Y to copy ; CTRL-/ for preview window'"

# enable command-not-found if installed
if [ -f /etc/zsh_command_not_found ]; then
    . /etc/zsh_command_not_found
fi

# Load starship prompt
eval "$(starship init zsh)"