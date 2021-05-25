#!/usr/bin/env bash

# Log the currently running command
command.log() {
	# Path to the currently actually executing 'action' script
	# This works on the assumption that 'source's are all absolute paths
	local currentAction="${BASH_SOURCE[2]}"
	local currentActionDirname="${currentAction%/*}"

	# TODO: improve output
	if [ "${currentActionDirname##*/}" = auto ]; then
		echo ":: RUNNING COMMAND -> auto/${currentAction##*/}"
	else
		echo "::: RUNNING COMMAND -> ${currentAction##*/}"
	fi
}
