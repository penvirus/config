# Wait as long as the evaluation statement is True.
# @eval_state: the evaluation statement
wait_as_long_as() {
	local eval_state="$1"

	while eval ${eval_state}; do
		echo -n '.'
		sleep 1
	done
}

wait_host_up() {
	local host_ip="$1"

	if [ -z "${host_ip}" ]; then
		return 1
	fi

	local e="! ping -q -c 1 -W 1 ${host_ip} >/dev/null"

	echo -n "waiting ${host_ip} up..."
	wait_as_long_as "${e}"
}

wait_host_down() {
	local host_ip="$1"

	if [ -z "${host_ip}" ]; then
		return 1
	fi

	local e="ping -q -c 1 -W 1 ${host_ip} >/dev/null"

	echo -n "waiting ${host_ip} down..."
	wait_as_long_as "${e}"
}
