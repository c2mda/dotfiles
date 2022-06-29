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
HOMEMACHINE="X-MBP-Perso-M1-2021.local"
if [ ${HOSTNAME} = ${HOMEMACHINE} ]; then
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
############################# ALIAS #####################################
#########################################################################
# Clear screen for real
alias cls='printf "\033c" && tmux clear-history'

# XClip
alias xclip='xclip -selection c'

# Python3
alias python=python3

#########################################################################
############################### FZF #####################################
#########################################################################
if [ -d ~/.fzf ]; then
  # Fzf completion
  [ -f ~/.fzf.bash ] && source ~/.fzf.bash

  # Set FZF default search to be exact
  export FZF_DEFAULT_OPTS="--exact"
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git --exclude /Library --exclude "Google Drive/.My Drive"'
  export FZF_CTRL_T_COMMAND='fd --type f --hidden --follow --exclude .git --exclude /Library --exclude "Google Drive/.My Drive"'
  export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git --exclude /Library --exclude "Google Drive/.My Drive"'

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
fi

#########################################################################
############################# VARIOUS ###################################
#########################################################################
# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

export EDITOR=vim
export TREE_CHARSET=ascii

# Enable color support of ls and also add handy aliases
alias ls='ls -alhG'

# Disable Ctrl+S locking the terminal
stty -ixon

# Set vi mode.
set -o vi

# Cycle through suggestions with TAB
bind "TAB:menu-complete"
set show-all-if-ambiguous on
set menu-complete-display-prefix on
set completion-ignore-case on


# Make directories light blue, not dark blue.
LS_COLORS="rs=0:di=01;36:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36"


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
fi
