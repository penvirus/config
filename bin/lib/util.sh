_wait_host() {
	local host=$1
	local exp=$2
	local e="ping -q -c 1 -W 1 ${host} >/dev/null"

	if [ "${exp}" = "up" ]; then
		e="! ${e}"
	fi

	echo -n "waiting ${host} ${exp}..."
	while eval ${e}; do
		echo -n '.'
		sleep 1
	done
	echo "done"
}

wait_host_up() {
	local host=$1

	if [ -z "${host}" ]; then
		return 1
	fi

	_wait_host "${host}" "up"
}

wait_host_down() {
	local host=$1

	if [ -z "${host}" ]; then
		return 1
	fi

	_wait_host "${host}" "down"
}
