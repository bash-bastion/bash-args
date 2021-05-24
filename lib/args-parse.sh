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

	# Array contaning all flags that should _not_ expect a value after
	local argsCommandBooleanFlags=()
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
			if [ "$line" = "$flagValueDefault" ]; then
				# The flag does not expect a value qualifier. To differentiate
				# @from passing in '{}' (a flag that defaults to empty), the
				# variable is unset
				unset flagValueDefault
			fi
			if [ "$line" = "$flagDescription" ]; then flagDescription=; fi

			# Sanity checks
			if [ -z "$flagNameOptional" ] && [ -z "$flagNameRequired" ]; then
				args.util.die 'args.parse: Must specify either an optional or required flag; neither were specified'
				return
			fi

			if [ -n "$flagNameOptional" ] && [ -n "$flagNameRequired" ]; then
				args.util.die 'args.parse: Must specify either an optional or required flag; both were specified'
				return
			fi

			# Set flagName, which always has a value unlike
			# flagNameOptional or flagNameRequired
			local flagName="${flagNameOptional:-"$flagNameRequired"}"
			local longFlag="${flagName%%.*}"
			local shortFlag="${flagName##*.}"
			if [ "$flagName" = "$shortFlag" ]; then shortFlag=; fi

			# Add to argsCommandBooleanFlags if applicable
			if [[ -v flagValueDefault ]]; then
				if [ -n "$longFlag" ]; then
					argsCommandBooleanFlags+=("$longFlag")
				fi

				if [ -n "$shortFlag" ]; then
					argsCommandBooleanFlags+=("$shortFlag")
				fi
			fi

			# shellcheck disable=SC1007
			local arg= currentFlag= flagWasFound=no didImmediateBreak=no
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
					return
				fi

				# If we were supposed to do an immediate break, but didn't actually
				# do it, it means we are on the last argument and there is no value
				if [ "$flagWasFound" = yes ] && [ "$didImmediateBreak" = no ]; then
					args.util.die "args.parse: No value found for flag '$currentFlag'"
					return
				fi
			fi

			# Set the default for the current flag. If there is no default,
			# it is just an empty assignment. If flagValueDefault is unset,
			# it means the flag is a boolean so we set the default to 'no'
			if [[ -v flagValueDefault ]]; then
				if [ -n "$longFlag" ]; then
					args+=(["$longFlag"]="${flagValueDefault:-}")
				fi

				if [ -n "$shortFlag" ]; then
					args+=(["$shortFlag"]="${flagValueDefault:-}")
				fi
			else
				if [ -n "$longFlag" ]; then
					args+=(["$longFlag"]=no)
				fi

				if [ -n "$shortFlag" ]; then
					args+=(["$shortFlag"]=no)
				fi
			fi

			# There is a flag with a possible value
			# the didImmediateBreak check ensures that the value of "$arg" isn't
			# the same as the last element (which is the flag option itself)
			if [ "$flagWasFound" = yes ] && [ "$didImmediateBreak" = yes ]; then
				case "$flagValueCli" in
					-*)
						if [[ -v flagValueDefault ]]; then
							args.util.die "args.parse: You must supply a value for '$currentFlag'"
							return
						fi
						;;
					*)
						# The user-supplied flag is valid, override the default
						if [[ -v flagValueDefault ]]; then
							if [ -n "$longFlag" ]; then
								args+=(["$longFlag"]="$arg")
							fi

							if [ -n "$shortFlag" ]; then
								args+=(["$shortFlag"]="$arg")
							fi
						else
							if [ -n "$longFlag" ]; then
								args+=(["$longFlag"]=yes)
							fi

							if [ -n "$shortFlag" ]; then
								args+=(["$shortFlag"]=yes)
							fi
						fi
				esac
			fi
		elif [ "$type" = "@arg" ]; then
			:
		else
			args.util.die "args.parse: Pragma must be either @flag or @arg"
			return
		fi
	done

	# generate argsCommands
	# note that so long as we check and exit on flags that
	# are not recognized, this should provide accurate results
	local argsCommandMode=append
	for arg; do
		if [ "$argsCommandMode" = skip ]; then
			argsCommandMode=append
			continue
		fi

		case "$arg" in
			-*)
				# We only skip the next argument if the current argument is NOT a
				# boolean argument
				local shouldSkip=yes
				for booleanArgs in "${argsCommandBooleanFlags[@]}"; do
					if [ "$booleanArgs" = "$arg" ]; then
						shouldSkip=no
						break
					fi
				done

				if [ "$shouldSkip" = yes ]; then
					argsCommandMode=skip
				fi
				;;
			*)
				if [ "$argsCommandMode" = append ]; then
					argsCommands+=("$arg")
				fi
		esac
	done
}
