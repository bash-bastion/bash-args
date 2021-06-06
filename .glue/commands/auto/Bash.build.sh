#!/usr/bin/env bash
eval "$GLUE_BOOTSTRAP"
bootstrap || exit

unset task
task() {
	ensure.file 'glue-auto.toml'
	toml.get_key 'version' 'glue-auto.toml'
	local newVersion="$REPLY"

	if [ -z "$newVersion" ]; then
		util.git_generate_version
		newVersion="$REPLY"
	fi

	util.general_version_bump "$newVersion"

	# glue useAction(util-Bash-version-bump.sh)
	util.get_action 'util-Bash-version-bump.sh'
	source "$REPLY" "$newVersion"
}

task "$@"
unset task

unbootstrap
