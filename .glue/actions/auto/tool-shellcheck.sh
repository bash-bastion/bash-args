#!/usr/bin/env bash
eval "$GLUE_BOOTSTRAP"
bootstrap

action() {
	ensure.cmd 'shellcheck'

	local exitCode=0

	util.shopt -u dotglob
	util.shopt -s globstar
	util.shopt -s nullglob

	if shellcheck --check-sourced -- ./**/?*.{sh,ksh,bash}; then : else
		if is.wet_release; then
			exitCode=$?
		fi
	fi

	REPLY="$exitCode"
}

action "$@"
unbootstrap
