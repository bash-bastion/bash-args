#!/usr/bin/env bash
eval "$GLUE_BOOTSTRAP"
bootstrap

action() {
	local -a dirs=()
	local exitCode=0

	ensure.cmd 'bats'
	(
		local exitCode=0

		if [ -d pkg ]; then
			ensure.cd 'pkg'

			dirs=(../test ../tests)
		else
			dirs=(test tests)
		fi

		for dir in "${dirs[@]}"; do
			if [ ! -d "$dir" ]; then
				continue
			fi

			if bats --recursive --output "." "$dir"; then : else
				exitCode=$?
			fi
		done

		return "$exitCode"
	); exitCode=$?

	REPLY="$exitCode"
}

action "$@"
unbootstrap
