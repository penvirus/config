#!/bin/sh

alias ls="ls --color -F"
alias ssh="ssh -A"
alias tmux="tmux -f ${HOME}/bin/tmux.conf"

if [ -n "${SSH_AUTH_SOCK}" -a -e "${SSH_AUTH_SOCK}" ]; then
	rm -f ${HOME}/bin/ssh_auth_sock
	ln -sf ${SSH_AUTH_SOCK} ${HOME}/bin/ssh_auth_sock
fi

if [ -n "${TMUX}" ]; then
	export SSH_AUTH_SOCK=${HOME}/bin/ssh_auth_sock
fi

export LS_COLORS="no=00:fi=00:di=01;34:ln=00;36:pi=40;33:so=00;35:bd=40;33;01:cd=40;33;01:or=01;05;37;41:mi=01;05;37;41:ex=00;32:*.sh=00;32:*.tar=00;31:*.tgz=00;31:*.zip=00;31:*.gz=00;31:*.bz2=00;31:*.bz=00;31:"
PS1="\[\033[1;32m\]\H\[\033[0m\]"
PS1="$PS1 \[\033[1;34m\]\W\[\033[0m\]"
PS1="$PS1 \[\033[1;31m\]-\u- (=^_^=)\[\033[0m\] "
export PS1

cm ()
{
	    curl -s -o - http://whatthecommit.com/ | sed -n '/<p>.*/p' | cut -d'>' -f2
}

export LC_ALL="en_US.UTF-8"
