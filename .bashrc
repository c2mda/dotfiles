export BASH_SILENCE_DEPRECATION_WARNING=1
# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return;;
esac

#########################################################################
############################# HISTORY ###################################
#########################################################################
# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth:erasedups

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000000
HISTFILESIZE=2000000
HISTTIMEFORMAT="%d%m%Y %T "

#########################################################################
############################# PROMPT ####################################
#########################################################################
# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
  xterm-color) color_prompt=yes ;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes
if [ -n "$force_color_prompt" ]; then
  if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    # We have color support; assume it's compliant with Ecma-48
    # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
    # a case would tend to support setf rather than setaf.)
    color_prompt=yes
  else
    color_prompt=
  fi
fi
unset color_prompt force_color_prompt

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No color.
HOMEMACHINE="XMBPPersoM12021.station"
HOMEMACHINE2="X-MBP-Perso-M1-2021.local"
if [[ ${HOSTNAME} = ${HOMEMACHINE} || ${HOSTNAME} = ${HOMEMACHINE2} ]]; then
  PCOLORHN=${RED}
else
  PCOLORHN=${BLUE}
fi
PS1="${PCOLORHN}>>>${GREEN}\$(eval \"p_dir\") ${NC}\n "
p_dir() {
  echo ${PWD}
}

# Save and reload the history after each command finishes
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

#########################################################################
############################### FZF #####################################
#########################################################################
# Fzf completion
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Completion on Debian system.
[ -f /usr/share/doc/fzf/examples/key-bindings.bash ] && source /usr/share/doc/fzf/examples/key-bindings.bash
[ -f /usr/share/doc/fzf/examples/completion.bash ] && source /usr/share/doc/fzf/examples/completion.bash

# Set FZF default search to be exact
if [ -f /usr/bin/fdfind ] && ! [ -f /opt/homebrew/bin/fd ]; then
  FDFIND='/usr/bin/fdfind -I'
else
# Fd does not respect .gitignore
  FDFIND='fd -I'
fi
export FZF_DEFAULT_OPTS='--exact --bind "ctrl-a:select-all,ctrl-d:deselect-all,ctrl-t:toggle-all"'
export FZF_DEFAULT_COMMAND="${FDFIND} --type f --hidden --follow --exclude .git --exclude /Library --exclude \"Google Drive/.My Drive\""
export FZF_CTRL_T_COMMAND="${FDFIND} --type f --hidden --follow --exclude .git --exclude /Library --exclude \"Google Drive/.My Drive\""
export FZF_ALT_C_COMMAND="${FDFIND} --type d --hidden --exclude .git --exclude /Library --exclude \"Google Drive/.My Drive\""

# Adapted from fzf/0.30.0/shell/key-bindings.bash fzf-file-widget
# Assume bash version > 4.0
fzf-vi-widget() {
  local selected="$(__fzf_select__)"
  READLINE_LINE="vi $selected"
}
bind -m vi-command -x '"\C-e": fzf-vi-widget'
bind -m vi-insert -x '"\C-e": fzf-vi-widget'

# Use C-f to cd to a directory with fzf.
# Default is Esc-c (\ec) but Esc doesn't work in bash vi mode.
bind -m vi-command '"\C-f": "\C-z\ec\C-z"'
bind -m vi-insert '"\C-f": "\C-z\ec\C-z"'

# CTRL-G open FZF, and searches history for strings that look like a path.
# Regex half-tested at https://regexr.com/4ljje
__fzf_select_path__() {
  local cmd="grep --only-matching --color=never -E -e '[[:alnum:].\`~_\/\-]*\/[[:alnum:].\`_\/\-]*' $HISTFILE"
  eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse --bind=ctrl-z:ignore $FZF_DEFAULT_OPTS $FZF_CTRL_T_OPTS" $(__fzfcmd) -m "$@" | while read -r item; do
    printf '%q ' "$item"
  done
  echo
}
fzf-path-widget(){
  local selected="$(__fzf_select_path__)"
  READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}$selected${READLINE_LINE:$READLINE_POINT}"
  READLINE_POINT=$(( READLINE_POINT + ${#selected} ))
}
bind -m vi-command -x '"\C-g": fzf-path-widget'
bind -m vi-insert -x '"\C-g": fzf-path-widget'

#########################################################################
############################# VARIOUS ###################################
#########################################################################
# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

export EDITOR=vim
export TREE_CHARSET=ascii

# Disable Ctrl+S locking the terminal
stty -ixon

# Set vi mode.
set -o vi

# Cycle through suggestions with tab. 
bind "TAB:menu-complete"

# Cycle backward with shift+tab.
bind '"\e[Z":menu-complete-backward'

# Use Alt + . to insert last argument of previous command.
bind -m vi-insert '"\e.": yank-last-arg'

# Only works for complete, not menu-complete, so useless.
set show-all-if-ambiguous on

# Show common prefix of possible completions on first tab.
set menu-complete-display-prefix on

# Ignore case.
set completion-ignore-case on

# Only works for complete, not menu-complete, so useless.
set completion-display-width 1

# Make directories ligher blue, don't highlight executable dirs.
# Use dircolors --print-database to understand.
LS_COLORS="rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=01;34:ow=01;34:st=37;44:ex=01;32"
export LS_COLORS

#########################################################################
############################# OSX ONLY ##################################
#########################################################################
if [[ $OSTYPE == 'darwin'* ]]; then
  # Add brew path to PATH
  eval $(/opt/homebrew/bin/brew shellenv)

  # The next line updates PATH for the Google Cloud SDK.
  if [ -f '/Users/x/google-cloud-sdk/path.bash.inc' ]; then . '/Users/x/google-cloud-sdk/path.bash.inc'; fi

  # The next line enables shell command completion for gcloud.
  if [ -f '/Users/x/google-cloud-sdk/completion.bash.inc' ]; then . '/Users/x/google-cloud-sdk/completion.bash.inc'; fi

  # Add keybase to PATH for git etc.
  export PATH=$PATH:/Applications/Keybase.app/Contents/SharedSupport/bin

  # Add gnubin.
  PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
fi

# Remove duplicate in PATH
# https://unix.stackexchange.com/questions/40749/remove-duplicate-path-entries-with-awk-command
PATH="$(perl -e 'print join(":", grep { not $seen{$_}++ } split(/:/, $ENV{PATH}))')"

# Less config for git and others.
# -e to quit at eof
# -F to output single screen files directly
# -R to output color sequence properly
# -Q to avoid using terminal bell
# -X to avoid clearing screen
export LESS="$LESS -eQFRX"
