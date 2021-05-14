#!/usr/bin/env bash
set -Eo pipefail

die() {
	log_error "${*-'die: '}. Exiting"
	exit 1
}

log_info() {
	rintf "\033[0;34m%s\033[0m\n" "Info: $*"
}

log_warn() {
	printf "\033[1;33m%s\033[0m\n" "Warn: $*" >&2
}

log_error() {
	printf "\033[0;31m%s\033[0m\n" "Error: $*" >&2
}

# TODO
arguments_show_help() {
	:
}

arguments() {
	# declare -A args=()

	local line
	while IFS= read -r line; do
		echo "LINE: $line"

		local type="${line%% *}"
		if [ "$type" = "@flag" ]; then
			# Parse
			local flagNameOptional="${line##*[}"; flagNameOptional="${flagNameOptional%%]*}"
			local flagNameRequired="${line##*<}"; flagNameRequired="${flagNameRequired%%>*}"
			local flagValueDefault="${line##*\{}"; flagValueDefault="${flagValueDefault%%\}*}"
			local flagDescription="${line##* -}"

			# If no value was found, ensure the variable is empty. This accounts
			# for the behavior of parameter expansion
			if [ "$line" = "$flagNameOptional" ]; then flagNameOptional=; fi
			if [ "$line" = "$flagNameRequired" ]; then flagNameRequired=; fi
			if [ "$line" = "$flagValueDefault" ]; then flagValueDefault=; fi
			if [ "$line" = "$flagDescription" ]; then flagDescription=; fi

			{
				echo ---
				echo "    flagNameOptional: $flagNameOptional"
				echo "    flagNameRequired: $flagNameRequired"
				echo "    flagValueDefault: $flagValueDefault"
				echo "    flagDescription: $flagDescription"
				echo ---
			} >&3

			# Process the flag
			if [ -z "$flagNameOptional" ] && [ -z "$flagNameRequired" ]; then
				die 'bash-arg: Must specify either an optional or required flag'
			fi

			if [ -n "$flagNameOptional" ] && [ -n "$flagNameRequired" ]; then
				die 'bash-arg: Must specify either an optional or required flag; NOT both'
			fi

			# Set flagName, an agnostic reference of either optional or required
			local flagName
			if [ -n "$flagNameOptional" ]; then
				flagName="$flagNameOptional"
			else
				flagName="$flagNameRequired"
			fi

			local longFlag="${flagName%%.*}"
			local shortFlag="${flagName##*.}"

			# If shortFlag wasn't actually specified, ensure it is blank
			if [ "$flagName" = "$shortFlag" ]; then shortFlag=; fi

			# Set the currentFlag, mainly for printing
			local currentFlag
			if [ -n "$longFlag" ]; then
				currentFlag="--$longFlag"
			else
				currentFlag="-$shortFlag"
			fi

			{
				echo "    longFlag: $longFlag"
				echo "    shortFlag: $shortFlag"
				echo ---
			} >&3

			# Look for the matching argument, then stay in loop
			# one extra iteration to get the value of the argument
			local arg flagWasFound=no didImmediateBreak=no
			for arg; do
				if [ "$flagWasFound" = yes ]; then
					didImmediateBreak=yes
					break
				fi

				if [ "$arg" = "--$longFlag" ]; then
					flagWasFound=yes
				elif [ "$arg" = "-$shortFlag" ]; then
					flagWasFound=yes
				fi
			done
			local flagValueCli="$arg"

			# If we did not set flagWasFound=yes, it means it did not find
			# the flag. So, if the flag is <required>, we fail right away
			if [ -n "$flagNameRequired" ] && [ "$flagWasFound" = no ]; then
				die "bash-arg: You must supply the flag '$currentFlag' with a value"
			fi

			# If we were supposed to do an immediate break, but didn't actually
			# do it, it means we are on the last argument and there is no value
			if [ "$flagWasFound" = yes ] && [ "$didImmediateBreak" = no ]; then
				die "bash-arg: No value found for flag '$currentFlag'"
			fi

			# Whether or not the flag was found, we set the default for the current
			# line, if one exists
			if [ -n "$longFlag" ]; then
				args+=(["$longFlag"]="$flagValueDefault")
			elif [ -n "$shortFlag" ]; then
				args+=(["$shortFlag"]="$flagValueDefault")
			fi


			# There is a flag with a possible value
			if [ "$flagWasFound" = yes ] && [ "$didImmediateBreak" = yes ]; then
				case "$flagValueCli" in
					-*)
						die "bash-arg: You must supply a value for '$currentFlag'"
						;;
					*)
						# The user-supplied flag is valid, override the default
						if [ -n "$longFlag" ]; then
							args+=(["$longFlag"]="$arg")
						elif [ -n "$shortFlag" ]; then
							args+=(["$shortFlag"]="$arg")
						fi
				esac
			fi
		elif [ "$type" = "@arg" ]; then
			# TODO: die with line, but only show line with debug mode
			die "bash-arg: Pragma must be either @flag or @arg\n    LINE: '$line'"
		fi
	done

	{
		echo +++
		for i in "${!args[@]}"; do
			echo "key  : $i"
			echo "value: ${args[$i]}"
			echo
		done
		echo +++
		echo; echo; echo
	} >&3

}
