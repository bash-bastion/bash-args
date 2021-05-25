#!/usr/bin/env bash

ensure.cmd() {
	if ! command -v "$1" &>/dev/null; then
		die "Command '$1' not found"
	fi
}

ensure.args() {
	local fnName="$1"
	local argNums="$2"
	shift; shift;

	local argNum
	for argNum in $argNums; do
		if [ -z "${!argNum}" ]; then
		# if [ -z "${@:$argNum:1}" ]; then
			echo "Context: '$0'" >&2
			echo "Context \${BASH_SOURCE[*]}: ${BASH_SOURCE[*]}" >&2
			log.error "ensure.args: Function '$fnName' has missing arguments" >&2
			exit 1
		fi
	done
}

ensure.nonZero() {
	varName="$1"
	varValue="$2"

	if [ -z "$varValue" ]; then
		die "ensure.nonZero: Variable '$varName' must be non zero"
	fi
}
