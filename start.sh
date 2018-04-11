#!/bin/sh

platform=$(uname -s)

distribute()
{
	rm -rf ${HOME}/.vim
	cp -r vim ${HOME}/.vim
	cp vimrc ${HOME}/.vimrc

	rm -rf ${HOME}/bin
	cp -r bin ${HOME}/bin

	if [ "$platform" = "Linux" ]; then
		ln -s ${HOME}/bin/jq-linux64 ${HOME}/bin/jq
	elif [ "$platform" = "Darwin" ]; then
		ln -s ${HOME}/bin/jq-osx-amd64 ${HOME}/bin/jq
	fi
	chmod u+x ${HOME}/bin/jq

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
