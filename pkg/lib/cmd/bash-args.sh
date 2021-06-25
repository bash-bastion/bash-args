# shellcheck shell=bash

source "$ARGS_LIB_DIR/util/util.sh"

declare -r PROGRAM_VERSION=""

bash-args-main() {
	local flag="${1:-}"

	if [ "$flag" = --version ]; then
		bash-args-show-version
	elif [ "$flag" = --help ]; then
		bash-args-show-help
	else
		echo "Error: Argument not recognized"
		bash-args-show-help
		exit 1
	fi
}

bash-args-show-help() {
	cat <<-EOF
	Program
	  bash-args

	Flags
	  --version
	    Show version of 'args.parse'

	  --help
	    Show help
	EOF
}

bash-args-show-version() {
	echo "$PROGRAM_VERSION"
}

bash-args-main "$@"
unset bash-args-main bash-args-show-help bash-args-show-version
