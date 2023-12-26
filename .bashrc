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
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No color.

function is_macbook()
{
  # Compare only letters.
  local compare="${HOSTNAME//[^[:alpha:]]/}"
  # Compare in lowercase.
  local compare=${compare,,}
  # Check if local machine.
  if [[ "${compare}" = *"xmbppersom"* ]]; then
    return 0
  fi 
  return 1
}

function get_color()
{
  local HN_COLORS=("$RED" "$GREEN" "$YELLOW" "$BLUE" "$MAGENTA")
  # Compare only letters.
  local compare="${HOSTNAME//[^[:alpha:]]/}"
  # Compare in lowercase.
  local compare=${compare,,}
  # Check if local machine.
  if [[ "${compare}" = *"xmbppersom"* ]]; then
    echo "${RED}"
  else
    local num_colors=${#HN_COLORS[@]}
    local color_index
    color_index=$(hostname | cksum | cut -f1 -d' ')
    echo "${HN_COLORS[$((color_index%num_colors-1))]}"
  fi
}
color=$(get_color)
PS1="${color}\u@\h>>>${GREEN}\w ${NC}\n "

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
export FZF_DEFAULT_OPTS='--exact --bind "ctrl-a:select-all,ctrl-d:deselect-all,ctrl-t:toggle-all"'
export FZF_DEFAULT_COMMAND="${FDFIND} --type f --hidden --follow --exclude .git --exclude /Library --exclude \"Google Drive/.My Drive\""
export FZF_CTRL_T_COMMAND="${FDFIND} --type f --hidden --follow --exclude .git --exclude /Library --exclude \"Google Drive/.My Drive\""
export FZF_ALT_C_COMMAND="${FDFIND} --type d --hidden --exclude .git --exclude /Library --exclude \"Google Drive/.My Drive\""

# Adapted from fzf/0.30.0/shell/key-bindings.bash fzf-file-widget
# Assume bash version > 4.0
fzf-vi-widget() {
  local selected
  selected="$(__fzf_select__)"
  if [ -n "$selected" ]; then
    READLINE_LINE="vi $selected"
  fi
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
  local selected
  selected="$(__fzf_select_path__)"
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
  eval "$(/opt/homebrew/bin/brew shellenv)"

  # The next line updates PATH for the Google Cloud SDK.
  if [ -f '/Users/x/google-cloud-sdk/path.bash.inc' ]; then . '/Users/x/google-cloud-sdk/path.bash.inc'; fi

  # The next line enables shell command completion for gcloud.
  if [ -f '/Users/x/google-cloud-sdk/completion.bash.inc' ]; then . '/Users/x/google-cloud-sdk/completion.bash.inc'; fi

  # Add keybase to PATH for git etc.
  export PATH=$PATH:/Applications/Keybase.app/Contents/SharedSupport/bin

  # Add gnubin.
  PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"

  # LSCOLORS has different syntax on OS X apparently.
  # https://apple.stackexchange.com/questions/282185/how-do-i-get-different-colors-for-directories-etc-in-iterm2
  LSCOLORS="EHfxcxdxBxegecabagacad"
  export LSCOLORS
fi

# Less config for git and others.
# -e to quit at eof
# -F to output single screen files directly
# -R to output color sequence properly
# -Q to avoid using terminal bell
# -X to avoid clearing screen
export LESS="$LESS -eQFRX"

# https://github.com/junegunn/fzf/blob/master/ADVANCED.md#using-fzf-as-interactive-ripgrep-launcher
# Require bat for preview and ripgrep.
# 1. Search for text in files using Ripgrep
# 2. Interactively restart Ripgrep with reload action
# 3. Open the file in Vim
rgfzf() {
  RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case "
  INITIAL_QUERY="${*:-}"
  # echo "test"
  : | fzf --ansi --disabled --query "$INITIAL_QUERY" \
      --bind "start:reload:$RG_PREFIX {q}" \
      --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
      --bind "alt-enter:unbind(change,alt-enter)+change-prompt(2. fzf> )+enable-search+clear-query" \
      --color "hl:-1:underline,hl+:-1:underline:reverse" \
      --prompt '1. ripgrep> ' \
      --delimiter : \
      --preview 'bat --color=always {1} --highlight-line {2}' \
      --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
      --bind 'enter:become(vim {1} +{2})'
}
# https://stackoverflow.com/questions/10980575/how-can-i-unbind-and-remap-c-w-in-bash
# Need to bind both mode explicitly for it to work in both.
bind -m vi-insert -x '"\C-w":"rgfzf"'
bind -m vi-command -x '"\C-w":"rgfzf"'

# Always add primary key to ssh agent on local machine.
if is_macbook; then
  ssh-add ~/.ssh/id_ed25519 &>/dev/null
fi

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/app/cyprien2/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/app/cyprien2/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/app/cyprien2/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/app/cyprien2/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
