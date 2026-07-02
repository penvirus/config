#!/bin/bash
# supported commands: abandon, branch, checkout, init, start, sync, upload, help
# should follow an existing branchname: abandon, checkout

_repo_bnames=""
_repo_invalidate_cache()
{
	local i_cmds=("start" "abandon")
	for ic in ${i_cmds[@]};
	do
		if [ "${COMP_WORDS[1]}" == "${ic}" ]; then
			_repo_bnames=""
			return
		fi
	done
}

_repo_completion()
{
	# command not given yet
	if [ ${COMP_CWORD} -eq 1 ]; then
		local all_cmds="abandon branch checkout init start sync upload help"
		COMPREPLY=($(compgen -W "${all_cmds}" "${COMP_WORDS[1]}"))
		return
	fi

	# for those should be the last command
	local end_cmds=("branch" "init" "start" "sync" "upload" "help")
	local cmd=${COMP_WORDS[1]}
	for ec in ${end_cmds[@]};
	do
		if [ "${cmd}" == "${ec}" ]; then
			_repo_invalidate_cache
			return
		fi
	done

	# for those have completed a branch name
	if [ ${COMP_CWORD} -ge 3 ]; then
		return
	fi

	# for those need a branch name
	if [ -z "${_repo_bnames}" ]; then
		# slow operation, a few seconds
		_repo_bnames="$(repo branch | grep '^*' | awk '{print $2}')"
	fi
	COMPREPLY=($(compgen -W "${_repo_bnames}" "${COMP_WORDS[2]}"))

	if [ ${#COMPREPLY[@]} -eq 1 ]; then
		_repo_invalidate_cache
	fi
}

complete -F _repo_completion repo
