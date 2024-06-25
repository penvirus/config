declare -A J_ARRAY
J_ARRAY[ll]="${HOME}/linux/linus"
J_ARRAY[lln]="${HOME}/linux/linux-next"
J_ARRAY[lc]="${HOME}/linux/chrome-platform"
J_ARRAY[lt]="${HOME}/linux/tb-chrome-platform"

j() {
	if [[ -z $1 ]]; then
		return
	fi

	dest=${J_ARRAY[$1]}
	if [[ -z $dest ]]; then
		dest="."
	fi

	cd "${dest}"
}
