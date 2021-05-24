# shellcheck shell=bash

args.parse() {
	# generate argsPostHyphen
	local appendMode=no
	for arg; do
		if [ "$appendMode" = yes ]; then
			argsPostHyphen+=("$arg")
		fi

		if [ "$arg" = "--" ]; then
			appendMode=yes
		fi
	done

	local line
	while IFS= read -r line; do
		argsRawSpec+="$line"$'\n'

		local type="${line%% *}"
		if [ "$type" = "@flag" ]; then
			# Parse lines; ensure each variable is blank if parsing did not find anything
			# (corrects for parameter expansion behavior)
			local flagNameOptional="${line##*[}"; flagNameOptional="${flagNameOptional%%]*}"
			local flagNameRequired="${line##*<}"; flagNameRequired="${flagNameRequired%%>*}"
			local flagValueDefault="${line##*\{}"; flagValueDefault="${flagValueDefault%%\}*}"
			local flagDescription="${line##* -}"
			if [ "$line" = "$flagNameOptional" ]; then flagNameOptional=; fi
			if [ "$line" = "$flagNameRequired" ]; then flagNameRequired=; fi
			if [ "$line" = "$flagValueDefault" ]; then flagValueDefault=; fi
			if [ "$line" = "$flagDescription" ]; then flagDescription=; fi

			# Sanity checks
			if [ -z "$flagNameOptional" ] && [ -z "$flagNameRequired" ]; then
				args.util.die 'args.parse: Must specify either an optional or required flag; neither were specified'
			fi

			if [ -n "$flagNameOptional" ] && [ -n "$flagNameRequired" ]; then
				args.util.die 'args.parse: Must specify either an optional or required flag; both were specified'
			fi

			# Set flagName, which always has a value unlike
			# flagNameOptional or flagNameRequired
			local flagName="${flagNameOptional:-"$flagNameRequired"}"
			local longFlag="${flagName%%.*}"
			local shortFlag="${flagName##*.}"
			if [ "$flagName" = "$shortFlag" ]; then shortFlag=; fi

			local currentFlag=
			local arg= flagWasFound=no didImmediateBreak=no
			for arg; do
				if [ "$arg" = "--" ]; then
					break
				fi

				if [ "$flagWasFound" = yes ]; then
					didImmediateBreak=yes
					break
				fi

				if [ "$arg" = "--$longFlag" ]; then
					currentFlag="--$longFlag"
					flagWasFound=yes
				elif [ "$arg" = "-$shortFlag" ]; then
					currentFlag="-$shortFlag"
					flagWasFound=yes
				fi
			done
			local flagValueCli="$arg"

			# If the flag name is required, we exit a failure if it's not there
			if [ -n "$flagNameRequired" ]; then
				# If we did not set flagWasFound=yes, it means it did not find
				# the flag. So, if the flag is <required>, we fail right away
				if [ "$flagWasFound" = no ]; then
					args.util.die "args.parse: You must supply the flag '$currentFlag' with a value"
				fi

				# If we were supposed to do an immediate break, but didn't actually
				# do it, it means we are on the last argument and there is no value
				if [ "$flagWasFound" = yes ] && [ "$didImmediateBreak" = no ]; then
					args.util.die "args.parse: No value found for flag '$currentFlag'"
				fi
			fi

			# Set the default for the current flag. If there is no default,
			# it is just an empty assignment
			if [ -n "$longFlag" ]; then
				args+=(["$longFlag"]="$flagValueDefault")
			fi

			if [ -n "$shortFlag" ]; then
				args+=(["$shortFlag"]="$flagValueDefault")
			fi

			# There is a flag with a possible value
			# the didImmediateBreak check ensures that the value of "$arg" isn't
			# the same as the last element (which is the flag option itself)
			if [ "$flagWasFound" = yes ] && [ "$didImmediateBreak" = yes ]; then
				case "$flagValueCli" in
					-*)
						args.util.die "args.parse: You must supply a value for '$currentFlag'"
						;;
					*)
						# The user-supplied flag is valid, override the default
						if [ -n "$longFlag" ]; then
							args+=(["$longFlag"]="$arg")
						fi

						if [ -n "$shortFlag" ]; then
							args+=(["$shortFlag"]="$arg")
						fi
				esac
			fi
		elif [ "$type" = "@arg" ]; then
			:
		else
			args.util.die "args.parse: Pragma must be either @flag or @arg"
		fi
	done
}
