#!/usr/bin/env bash

# TODO: make more pOsiX
DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
source "$DIR/../lib/util.sh"

main() {
	local indent="    "
	local -a flagArray=() argArray=()

	local line
	while IFS= read -r line; do
		local type="${line%% *}"
		if [ "$type" = "@flag" ]; then
			# Perform same parsin functions as in 'args.sh'. It looks a little messy because
			# we're not calling shared functions, invoking subshells in the process (pun intended)
			local flagNameOptional="${line##*[}"; flagNameOptional="${flagNameOptional%%]*}"
			local flagNameRequired="${line##*<}"; flagNameRequired="${flagNameRequired%%>*}"
			local flagValueDefault="${line##*\{}"; flagValueDefault="${flagValueDefault%%\}*}"
			local flagDescription="${line##* -}"
			if [ "$line" = "$flagNameOptional" ]; then flagNameOptional=; fi
			if [ "$line" = "$flagNameRequired" ]; then flagNameRequired=; fi
			if [ "$line" = "$flagValueDefault" ]; then flagValueDefault=; fi
			if [ "$line" = "$flagDescription" ]; then flagDescription=; fi

			# This is different compared to `args.sh`
			local flagNameCombo longFlag shortFlag
			if [ -n "$flagNameOptional" ]; then
				longFlag="--${flagNameOptional%%.*}"
				shortFlag="-${flagNameOptional##*.}"

				# tests if a short flag was actually given
				if [ "$shortFlag" != "-$flagNameOptional" ]; then
					flagNameCombo="[$longFlag, $shortFlag]"
				else
					flagNameCombo="[$longFlag]"
				fi
			else
				longFlag="--${flagNameRequired%%.*}"
				shortFlag="-${flagNameRequired##*.}"

				# tests if a short flag was actually given
				if [ "$shortFlag" != "-$flagNameRequired" ]; then
					flagNameCombo="<$longFlag, $shortFlag>"
				else
					flagNameCombo="<$longFlag>"
				fi
			fi

			flagDefault=
			if [ -n "$flagValueDefault" ]; then
				flagDefault=" (default: $flagValueDefault)"
			fi

			# Append flags
			flagArray+=("$indent${flagNameCombo}$flagDefault -$flagDescription"$'\n')
		elif [ "$type" = "@arg" ]; then
			# Append arguments
			argArray+=("$indent<no specification available>"$'\n')
		fi
	done

	execName="${0##*/}"
	if [ "$execName" = "args-help.sh" ]; then
		execName="stdin"
	fi

	# TODO: description can wrap around incorrectly
	if [ -n "$description" ]; then
		printf -v descriptionOutput "\nDescription:\n"
	fi

	oldIFS="$IFS"
	IFS=
	if [ "${#flagArray[@]}" -gt 0 ]; then
		printf -v flagOutput "\nFlags:\n%s" "${flagArray[*]}"

		# Since flagOutput is the last thing to print, strip any hanging newlines
		if [ "${flagOutput: -1}" = $'\n' ]; then
			flagOutput="${flagOutput::-1}"
		fi
	fi

	if [ "${#argArray[@]}" -gt 0 ]; then
		printf -v argumentOutput "\nArguments:\n%s" "${argArray[*]}"
	fi

	IFS="$oldIFS"

	cat <<-EOF
	Usage:
	    $execName [flags] [<requiredFlags>] <arguments>
	${descriptionOutput}${argumentOutput}${flagOutput}
	EOF

}

main "$@"
