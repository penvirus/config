#!/bin/sh

platform=$(uname -s)

distribute()
{
	cp -r vim ${HOME}/.vim
	cp vimrc ${HOME}/.vimrc

	mkdir -p ${HOME}/bin
	cp bashrc ${HOME}/bin/
	cp tmux.conf ${HOME}/bin/

	if [ "$platform" = "Linux" ]; then
		sed -i /gg_config_gg/d ${HOME}/.bashrc
	elif [ "$platform" = "Darwin" ]; then
		sed -i '' /gg_config_gg/d ${HOME}/.bashrc
	fi
	echo '. ${HOME}/bin/bashrc #gg_config_gg' >> ${HOME}/.bashrc

	cp gitconfig ${HOME}/.gitconfig
}

collect()
{
	sleep 1
}

if [ -z "$1" ]; then
	echo "$0 [0 | 1]"
	echo "  0: distribute"
	echo "  1: collect"
else
	if [ "$1" -eq 0 ]; then
		distribute
	else
		collect
	fi
fi
