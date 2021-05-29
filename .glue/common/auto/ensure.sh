#!/usr/bin/env bash

ensure.cmd() {
	local cmd="$1"

	if ! command -v "$cmd" &>/dev/null; then
		die "Command '$cmd' not found"
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
	local varName="$1"
	local varValue="$2"

	if [ -z "$varValue" ]; then
		die "ensure.nonZero: Variable '$varName' must be non zero"
	fi
}

ensure.file() {
	local fileName="$1"

	if [ ! -f "$fileName" ]; then
		die "ensure.file: File '$fileName' does not exist"
	fi
}

ensure.dir() {
	local dirName="$1"

	if [ ! -f "$dirName" ]; then
		die "ensure.file: File '$dirName' does not exist"
	fi
}
