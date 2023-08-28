prepare_gpg() {
	export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
	killall gpg-agent
	export GPG_TTY=$(tty)
	gpg-connect-agent updatestartuptty /bye >/dev/null

	export PS1="(gpg) $PS1"
}
