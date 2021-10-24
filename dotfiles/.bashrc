#!/bin/bash
# heavily inspired by ubuntu's default .bashrc

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

shopt -s histappend

HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

function git_branch() {
    current_branch=$(git branch 2>/dev/null | grep '^*' | colrm 1 2)
    if [[ -z "$current_branch" ]]; then
        echo ""
    else
        echo " $current_branch"
    fi
}

PS1='\[\e[0;1;96m\]\u \[\e[0m\]\[\e[0;3m\]@ \[\e[0;3;95m\]\h \n\[\e[0;1;96m\]\w$(git_branch)\[\e[0;1;3;92m\] ⤙ \[\e[0m\]'

PROMPT_COMMAND="export PROMPT_COMMAND=echo"

test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

. "$HOME"/.aliasrc

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
