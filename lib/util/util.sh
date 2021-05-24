#!/usr/bin/env bash

args.util.die() {
	if [[ -n "$*" ]]; then
		args.util.log_error "$*. Exiting"
	else
		args.util.log_error "Exiting"
	fi

	exit 1
}

args.util.log_info() {
	if [[ -v NO_COLOR || $TERM = dumb ]]; then
		printf "%s\n" "Info: $*"
	else
		printf "\033[0;34m%s\033[0m\n" "Info: $*"
	fi
}

args.util.log_warn() {
	if [[ -v NO_COLOR || $TERM = dumb ]]; then
		printf "%s\n" "Warn: $*"
	else
		printf "\033[1;33m%s\033[0m\n" "Warn: $*" >&2
	fi
}

args.util.log_error() {
	if [[ -v NO_COLOR || $TERM = dumb ]]; then
		printf "%s\n" "Error: $*"
	else
		printf "\033[0;31m%s\033[0m\n" "Error: $*" >&2
	fi
}
