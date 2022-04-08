# shellcheck shell=bash

bash_args.print.info() {
	if [[ -v NO_COLOR || $TERM = dumb ]]; then
		printf "%s\n" "Info: $*"
	else
		printf "\033[0;34m%s\033[0m\n" "Info: $*"
	fi
}

bash_args.print.warn() {
	if [[ -v NO_COLOR || $TERM = dumb ]]; then
		printf "%s\n" "Warn: $*"
	else
		printf "\033[1;33m%s\033[0m\n" "Warn: $*" >&2
	fi
}

bash_args.print.error() {
	if [[ -v NO_COLOR || $TERM = dumb ]]; then
		printf "%s\n" "Error: $*"
	else
		printf "\033[0;31m%s\033[0m\n" "Error: $*" >&2
	fi
}
