#!/usr/bin/env bash

# Log the currently running command
command.log() {
	# Path to the currently actually executing 'action' script
	# This works on the assumption that 'source's are all absolute paths
	local currentCommand="${BASH_SOURCE[2]}"
	local currentCommandDirname="${currentCommand%/*}"

	if [ "${currentCommandDirname##*/}" = auto ]; then
		if [[ "${LANG,,?}" == *utf?(-)8 ]]; then
			echo "■■ 🢂  START COMMAND -> auto/${currentCommand##*/}"
		else
			echo ":: => START COMMAND -> auto/${currentCommand##*/}"
		fi
	else
		if [[ "${LANG,,?}" == *utf?(-)8 ]]; then
			echo "■■ 🢂  START COMMAND -> ${currentCommand##*/}"
		else
			echo ":: => START COMMAND -> ${currentCommand##*/}"
		fi
	fi
}
