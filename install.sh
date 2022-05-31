#!/bin/sh

platform=$(uname -s)

distribute()
{
	rm -rf ${HOME}/.vim
	cp -r vim ${HOME}/.vim
	cp vimrc ${HOME}/.vimrc

	rm -rf ${HOME}/bin
	cp -r bin ${HOME}/bin

	rm -rf ${HOME}/.gnupg
	cp -r gpg ${HOME}/.gnupg

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

	# because of login shell
	if [ "$platform" = "Darwin" ]; then
		if [ -f ${HOME}/.profile ]; then
			sed -i '' /gg_config_gg/d ${HOME}/.profile
		fi

		echo '. ${HOME}/bin/bashrc #gg_config_gg' >> ${HOME}/.profile
	fi

	cp gitconfig ${HOME}/.gitconfig

	echo 'source ~/bin/tigrc' >${HOME}/.tigrc
}

distribute
