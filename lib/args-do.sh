# shellcheck shell=bash

source "$ARGS_ROOT_DIR/lib/do/print-help.sh"

args.do() {
	case "$1" in
		print-help)
		shift
		do_print_help
	esac
}
