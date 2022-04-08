# shellcheck shell=bash

main.barg() {
	local -a pre_hyphen=()
	local -a post_hyphen=()

	# shellcheck disable=SC1007
	local arg= has_passed_hyphen='no'
	for arg; do
		if [ "$has_passed_hyphen" = 'no' ] && [ "$arg" = '---' ]; then
			has_passed_hyphen='yes'
			continue
		fi

		if [ "$has_passed_hyphen" = 'no' ]; then
			pre_hyphen+=("$arg")
		else
			post_hyphen+=("$arg")
		fi
	done; unset -v arg

	local -A args=() _args=() _args_maplong=() _args_mapshort=()
	barg.define_flags "${pre_hyphen[@]}"
	barg.parse_flags "${post_hyphen[@]}"
}
