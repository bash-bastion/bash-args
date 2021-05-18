#!/usr/bin/env bash

# Pretty log the currently running command
action.log() {
	# ${BASH_SOURCE[0]}: Ex. ~/.../.glue/actions/auto/util/action.sh
	# ${BASH_SOURCE[1]}: Ex. ~/.../.glue/actions/auto/util/bootstrap.sh
	# ${BASH_SOURCE[2]}: Ex. ~/.../.glue/actions/auto/do-tool-prettier-init.sh

	# Path to the currently actually executing 'action' script
	# This works on the assumption that 'source's are all absolute paths
	local currentAction="${BASH_SOURCE[2]}"
	local currentActionDirname="${currentAction%/*}"

	# TODO: improve output
	if [ "${currentActionDirname##*/}" = auto ]; then
		echo ":: :: RUNNING ACTION -> auto/${currentAction##*/}"
	else
		echo ":: :: RUNNING ACTION -> ${currentAction##*/}"
	fi
}
