# Clear screen for real
alias cls='printf "\033c" && [ -n "$TMUX" ] && tmux clear-history'

# XClip
alias xclip='xclip -selection c'

# Python3
alias python=python3.9

#€ On debian fd is renamed fdfind
if [ -f /usr/bin/fdfind ] && ! [ -f /opt/homebrew/bin/fd ]; then
  FDFIND='/usr/bin/fdfind -I'
else
# Fd does not respect .gitignore
  FDFIND='fd -I'
fi
alias fd="$FDFIND"

# Enable color support of ls and also add handy aliases
alias ls='ls --color=auto -alh'

if [[ $OSTYPE == 'darwin'* ]]; then
  # Add Visual Studio Code (code)
  export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
fi

# Add $HOME/.local/bin to PATH (pip installs command line scripts there).
export PATH=$HOME/.local/bin:$PATH

# Add /home/cyprien/bin for eg oci.
export PATH=$HOME/bin:$PATH

# Remove duplicate in PATH
# https://unix.stackexchange.com/questions/40749/remove-duplicate-path-entries-with-awk-command
PATH="$(perl -e 'print join(":", grep { not $seen{$_}++ } split(/:/, $ENV{PATH}))')"

if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
fi

source ~/.bashrc
