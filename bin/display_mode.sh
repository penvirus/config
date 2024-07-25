#!/bin/sh

if [ -z "$1" ]; then
	exit 1
fi

case "$1" in
	"standalone")
		xrandr --output eDP --mode 2256x1504 --scale 1 --primary \
			--output DisplayPort-1 --off \
			--output DisplayPort-2 --off

		i3-msg "workspace 1, move workspace to output primary"
		i3-msg "workspace 2, move workspace to output primary"
		i3-msg "workspace 3, move workspace to output primary"
		i3-msg "workspace 4, move workspace to output primary"
		;;

	"extended")
		xrandr --output eDP --primary \
			--output DisplayPort-1 --off \
			--output DisplayPort-2 --mode 3840x2160 --scale 0.75 --left-of eDP

		i3-msg "workspace 1, move workspace to output primary"
		i3-msg "workspace 2, move workspace to output DisplayPort-2"
		i3-msg "workspace 3, move workspace to output primary"
		i3-msg "workspace 4, move workspace to output primary"
		;;

	"docked")
		xrandr --output eDP --mode 2256x1504 --scale 0.75 \
			--output DisplayPort-1 --mode 3840x2160 --scale 0.75 --right-of eDP --primary \
			--output DisplayPort-2 --off

		i3-msg "workspace 1, move workspace to output primary"
		i3-msg "workspace 2, move workspace to output primary"
		i3-msg "workspace 3, move workspace to output primary"
		i3-msg "workspace 4, move workspace to output eDP"

		;;
esac

i3-msg "workspace number 1"
