if [ ! -d "${HOME}/i3" ]; then
	git clone https://github.com/i3/i3.git "${HOME}/i3"
fi

#sudo apt update
sudo apt install -y libxcb1-dev libxcb-keysyms1-dev libxcb-util0-dev \
	libxcb-icccm4-dev libyajl-dev libstartup-notification0-dev \
	libxcb-randr0-dev libev-dev libxcb-xinerama0-dev libxcb-xkb-dev \
	libxcb-shape0-dev libxcb-cursor-dev libxcb-xrm-dev libxkbcommon-dev \
	libxkbcommon-x11-dev libpcre2-dev libcairo2-dev librust-pangocairo-dev \

cd "${HOME}/i3"
meson setup builddir
cd builddir
meson compile

sudo rm -f /usr/share/xsessions/myi3.desktop
sudo tee /usr/share/xsessions/myi3.desktop <<EOF
[Desktop Entry]
Name=myi3
Comment=improved dynamic tiling window manager
Exec=${HOME}/i3/builddir/i3
TryExec=i3
Type=Application
X-LightDM-DesktopName=i3
DesktopNames=myi3
Keywords=tiling;wm;windowmanager;window;manager;
EOF
