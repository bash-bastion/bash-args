#!/usr/bin/env bash

ensure.cmd() {
	if ! command -v "$1" &>/dev/null; then
		die "Command '$1' not found"
	fi
}

ensure.args() {
	fnName="$1"
	shift

	n=1
	for arg; do
		if [ -z "$arg" ]; then
			die "$fnName: Argument $n missing"
		fi

		n=$((n+1))
	done
}
