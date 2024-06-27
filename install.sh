#!/bin/sh

platform=$(uname -s)

install_jq()
{
	if [ "$platform" = "Linux" ]; then
		ln -s "${HOME}/bin/jq-linux64" "${HOME}/bin/jq"
	elif [ "$platform" = "Darwin" ]; then
		ln -s "${HOME}/bin/jq-osx-amd64" "${HOME}/bin/jq"
	fi
}

install_bashrc()
{
	if [ "$platform" = "Linux" ]; then
		sed -i /gg_config_gg/d "${HOME}/.bashrc"
	elif [ "$platform" = "Darwin" ]; then
		sed -i '' /gg_config_gg/d "${HOME}/.bashrc"

		# because of login shell
		if [ -f "${HOME}/.profile" ]; then
			sed -i '' /gg_config_gg/d "${HOME}/.profile"
		fi
		echo '. ${HOME}/bin/bashrc #gg_config_gg' >> "${HOME}/.profile"
	fi
	echo '. ${HOME}/bin/bashrc #gg_config_gg' >> "${HOME}/.bashrc"
}

install_bin()
{
	rm -rf "${HOME}/bin"
	cp -r --preserve=all bin "${HOME}/bin"

	install_jq
	install_bashrc
}

install_vim()
{
	rm -rf "${HOME}/.vim"
	cp -r --preserve=all dot/vim "${HOME}/.vim"

	cp --preserve=all dot/vimrc "${HOME}/.vimrc"

	mkdir -p "${HOME}/.vim/pack/tpope/start"
	git -C "${HOME}/.vim/pack/tpope/start" clone https://tpope.io/vim/fugitive.git
}

install_gpg()
{
	mkdir -p "${HOME}/.gnupg"
	cp --preserve=all dot/gpg/gpg-agent.conf "${HOME}/.gnupg/"
	cp --preserve=all dot/gpg/gpg.conf "${HOME}/.gnupg/"
	cp --preserve=all dot/gpg/sshcontrol "${HOME}/.gnupg/"
	chmod -R 700 "${HOME}/.gnupg"
}

install_git()
{
	cp --preserve=all dot/gitconfig "${HOME}/.gitconfig"
}

install_tig()
{
	cp --preserve=all dot/tigrc "${HOME}/.tigrc"
}

install_mutt()
{
	cp --preserve=all dot/muttrc "${HOME}/.muttrc"

	rm -rf "${HOME}/.mutt"
	cp -r --preserve=all dot/mutt "${HOME}/.mutt"
}

install_ssh()
{
	mkdir -p "${HOME}/.ssh"
	chmod 700 "${HOME}/.ssh"
	cp --preserve=all dot/ssh_config "${HOME}/.ssh/config"
}

install_i3()
{
	rm -rf "${HOME}/.config/i3"
	mkdir -p "${HOME}/.config/i3"
	cp --preserve=all dot/i3_config "${HOME}/.config/i3/config"
	cp --preserve=all dot/i3status.conf "${HOME}/.i3status.conf"
	cp --preserve=all dot/Xresources "${HOME}/.Xresources"
}

install_alacritty()
{
	rm -rf "${HOME}/.config/alacritty/themes"
	mkdir -p "${HOME}/.config/alacritty/themes"
	git clone https://github.com/alacritty/alacritty-theme "${HOME}/.config/alacritty/themes"

	cp --preserve=all dot/alacritty.toml "${HOME}/.alacritty.toml"
	cp --preserve=all dot/alacritty.yml "${HOME}/.alacritty.yml"
}

install_touchpad()
{
	if [ -d /etc/X11/xorg.conf.d/ ]; then
		sudo cp --preserve=all touchpad/90-touchpad.conf /etc/X11/xorg.conf.d/
	fi
}

install_libinput_gestures()
{
	# usermod -a -G input $USER
	# apt install wmctrl xdotool libinput-tools
	rm -rf "${HOME}/bin/libinput-gestures"
	mkdir -p "${HOME}/bin/libinput-gestures"
	git clone https://github.com/bulletmark/libinput-gestures.git "${HOME}/bin/libinput-gestures"

	cp --preserve=all dot/libinput-gestures.conf "${HOME}/.libinput-gestures.conf"
}

distribute()
{
	install_bin
	install_vim
	install_gpg
	install_git
	install_tig
	install_mutt
	install_ssh

	install_i3
	install_alacritty
	install_touchpad
	install_libinput_gestures
}

distribute
