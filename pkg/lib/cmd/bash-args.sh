# shellcheck shell=bash

source "$BASH_ARGS_LIB_DIR/util/util.sh"

# TODO: namespace the entrypoint, and ensure to unset the variables after
# Not readonly as this is sourced. This also should read 'BASH_ARGS_VERSION',
# not 'PROGRAM_VERSION' since this file is sourced and 'PROGRAM_VERSION'
# is more generic
declare BASH_ARGS_VERSION="0.7.0+916ca13-DIRTY"

bash-args() {
	case "$1" in
	-h|--help)
		cat <<-EOF
		Program:
		    bash-args

		Subcommands:
		    parse
		        Perform the parsing. Append all arguments after this subcommand

		Flags
		--version
			Show version of 'args.parse'

		--help
			Show help
		EOF
		return
		;;
	-v|--version)
		cat <<-"EOF"
			Version: $BASH_ARGS_VERSION
		EOF
		return
		;;
	parse)
		shift
		;;
	*)
		bash_args.util.die "Argument not recognized. See '--help' for help"
		return
		;;
	esac

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

	# Array contaning all flags that should _not_ expect subsequent value
	local -a argsCommandBooleanFlags=()

	# Array containing all arguments for help menu
	local -a argsHelpArrayArgs=()

	# Array containing all flags for help menu
	local -a argsHelpArrayFlags=()

	# Array containing all flags
	local -a argsAllFlags=()

	local line
	while IFS= read -r line; do
		argsRawSpec+="$line"$'\n'

		if [ -z "$line" ]; then
			continue
		fi

		local type="${line%% *}"
		if [ "$type" = "@flag" ]; then
			# Parse line
			# TODO: condence flagNameOptional and flagNameRequired with extglob features
			local flagNameOptional="${line##*[}"; flagNameOptional="${flagNameOptional%%]*}"
			local flagNameRequired="${line##*<}"; flagNameRequired="${flagNameRequired%%>*}"
			local flagValueDefault="${line##*\{}"; flagValueDefault="${flagValueDefault%%\}*}"
			local flagDescription="${line##* -}"

			# Ensure each variable is blank if parsing did not find anything. This corrects for parameter
			# expansion behavior, since no modifications to the original line if a match was not found
			if [ "$line" = "$flagNameOptional" ]; then flagNameOptional=; fi
			if [ "$line" = "$flagNameRequired" ]; then flagNameRequired=; fi
			if [ "$line" = "$flagValueDefault" ]; then
				# We must differentiate between specifying in '{}' (a flag that defaults to empty), and not
				# specifying '{}'. If '{}' is specified (default empty flag), this variable is unset;
				# otherwise, if '{}' is not specified at all, the variable is unset. If unset, we expect
				# the flag to be ONLY a boolean flag, and expect no values to follow it (only more flags)
				unset flagValueDefault
			fi
			if [ "$line" = "$flagDescription" ]; then flagDescription=; fi

			# Sanity checks
			if [ -z "$flagNameOptional" ] && [ -z "$flagNameRequired" ]; then
				bash_args.util.die 'args.parse: Must specify either an optional or required flag; neither were specified'
				return
			fi

			if [ -n "$flagNameOptional" ] && [ -n "$flagNameRequired" ]; then
				bash_args.util.die 'args.parse: Must specify either an optional or required flag; both were specified'
				return
			fi

			# Set 'longFlag' and 'shortFlag', using 'flagName' as an intermediary value so it works
			# whether the line specifies either an optional or a required argument
			local flagName="${flagNameOptional:-"$flagNameRequired"}"
			local longFlag="${flagName%%.*}"
			local shortFlag="${flagName##*.}"

			# Like above, we account for the behavior of parameter expansion, ensuring 'shortFlag' is empty
			# if it was not provided (i.e, longFlag was only provided). We do not do this
			# for 'longFlag' because if it was not provided (i.e., only 'shortFlag' was provided), the
			# dot is still required to be there (to differentiate it from a long flag), so the parameter
			# expansion is guaranteed to work
			if [ "$flagName" = "$shortFlag" ]; then shortFlag=; fi

			# Append to argsCommandBooleanFlags, if applicable, to be used later for enduring
			# a flag is not supposed to have any value specifier following it
			if [[ ! -v flagValueDefault ]]; then
				if [ -n "$longFlag" ]; then
					argsCommandBooleanFlags+=("$longFlag")
				fi

				if [ -n "$shortFlag" ]; then
					argsCommandBooleanFlags+=("$shortFlag")
				fi
			fi

			# Append to argsAllFlags, if applicable, to be used later for ensuring
			# a particular flag was actually specified in the stdin spec
			if [ -n "$longFlag" ]; then
				argsAllFlags+=("--$longFlag")
			fi

			if [ -n "$shortFlag" ]; then
				argsAllFlags+=("-$shortFlag")
			fi

			# TODO: rename
			# Set the 'currentFlag' or flags for pretty printing the supplied
			# flags (short and long) for the current line
			local currentFlag=
			if [[ -n "$longFlag" && -n "$shortFlag" ]]; then
				currentFlag="--$longFlag or -$shortFlag"
			elif [ -n "$longFlag" ]; then
				currentFlag="--$longFlag"
			elif [ -n "$shortFlag" ]; then
				currentFlag="-$shortFlag"
			fi

			# shellcheck disable=SC1007
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
					flagWasFound=yes
				elif [ "$arg" = "-$shortFlag" ]; then
					flagWasFound=yes
				fi
			done
			local flagValueCli="$arg"

			# Debug
			if [[ -v DEBUG_BASH_ARGS ]]; then
				# Ensure the third file descriptor is valid for writing. We use 3 because
				# it's printed to the terminal when testing with Bats using the TAP formatter
				if ! : >&3; then
					exec 3>&1
				fi 2>/dev/null

				cat >&3 <<-EOF
				flagNameOptional: $flagNameOptional
				flagNameRequired: $flagNameRequired
				flagValueDefault: ${flagValueDefault-"NOT SET"}
				flagDescription: $flagDescription

				flagName: $flagName
				longFlag: $longFlag
				shortFlag: $shortFlag

				argsCommandBooleanFlags: ${argsCommandBooleanFlags[@]}
				argsAllFlags: ${argsAllFlags[@]}
				currentFlag: $currentFlag
				flagValueCli: $flagValueCli
				EOF
			fi

			# If the flag name is required, we exit a failure if it's not there
			if [ -n "$flagNameRequired" ]; then
				# If we did not set flagWasFound=yes, it means it did not find
				# the flag. So, if the flag is <required>, we fail right away
				if [ "$flagWasFound" = no ]; then
					bash_args.util.die "args.parse: You must supply the flag '$currentFlag' with a value"
					return
				fi

				# If we were supposed to do an immediate break, but didn't actually
				# do it, it means we are on the last argument and there is no value
				if [ "$flagWasFound" = yes ] && [ "$didImmediateBreak" = no ]; then
					bash_args.util.die "args.parse: No value found for flag '$currentFlag'"
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
							bash_args.util.die "args.parse: You must supply a value for '$currentFlag'"
							return
						fi
						;;
					*)
						# The user-supplied flag is valid, override the default
						if [[ -v flagValueDefault ]]; then
							if [ -n "$longFlag" ]; then
								args+=(["$longFlag"]="$flagValueCli")
							fi

							if [ -n "$shortFlag" ]; then
								args+=(["$shortFlag"]="$flagValueCli")
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
			# This is the last element of "$@". It only applies to boolean options
			elif [ "$flagWasFound" = yes ] && [ "$didImmediateBreak" = no ]; then
				if [ -n "$longFlag" ]; then
					args+=(["$longFlag"]=yes)
				fi

				if [ -n "$shortFlag" ]; then
					args+=(["$shortFlag"]=yes)
				fi
			fi

			# Construct 'argsHelpText'

			# shellcheck disable=SC1007
			local flagNameCombo= flagDescription=

			# Option
			if [[ -n "$longFlag" && -n "$shortFlag" ]]; then
				flagNameCombo="$shortFlag, $longFlag"
			elif [ -n "$shortFlag" ]; then
				flagNameCombo="$shortFlag"
			elif [ -n "$longFlag" ]; then
				flagNameCombo="$longFlag"
			fi

			if [ -n "$flagNameRequired" ]; then
				# flagNameCombo="$flagNameCombo <>"

				if [ -n "$flagDescription" ]; then
					flagDescription="(Required) $flagDescription"
				else
					flagDescription="(Required)"
				fi
			fi

			if [[ -v flagValueDefault ]]; then
				if [ -n "$flagDescription" ]; then
					flagDescription="(Default: $flagValueDefault) $flagDescription"
				else
					flagDescription="(Default: $flagValueDefault)"
				fi
			fi

			# TODO: description can wrap around incorrectly
			flagNameCombo="  ${flagNameCombo}"
			if [ "${#flagNameCombo}" -lt 20 ]; then
				printf -v flagNameCombo '%-20s' "$flagNameCombo"
				argsHelpArrayFlags+=("${flagNameCombo}$flagDescription"$'\n')
			else
				argsHelpArrayFlags+=("${flagNameCombo}\n$flagDescription"$'\n')
			fi

		elif [ "$type" = "@arg" ]; then
			local name="${line#* }"; name="${name%% *}"
			local argDescription="${line##* - }"

			# for argsHelpText
			printf -v name '%-20s' "  $name"
			argsHelpArrayArgs+=("${name}${argDescription}"$'\n')
		else
			bash_args.util.die "args.parse: Pragma must be either @flag or @arg. Received: '$type'"
			return
		fi
	done

	# Construct 'argsCommands'. Note that this ONLY provides accurate results if we check and exit the
	# program on flags that are not recognized
	local argsCommandMode=append
	for arg; do
		if [ "$argsCommandMode" = skip ]; then
			argsCommandMode=append
			continue
		fi

		case "$arg" in
			-*)
				# We only skip the next argument if the current
				# argument is NOT a boolean argument
				local shouldSkip=yes
				for booleanArg in "${argsCommandBooleanFlags[@]}"; do
					local cutArg="${arg/#-/}"
					cutArg="${cutArg/#-/}"

					if [ "$booleanArg" = "$cutArg" ]; then
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

	# use argsAllFlags to ensure no invalid arguments
	for arg; do
		case "$arg" in
		-) ;;
		--) break ;;
		-*)
			local isValidFlag=no
			for flag in "${argsAllFlags[@]}"; do
				if [ "$flag" = "$arg" ]; then
					isValidFlag=yes
					break
				fi
			done

			if [ "$isValidFlag" = no ]; then
				bash_args.util.die "args.parse: Flag '$arg' is not accepted"
				return
			fi
		esac
	done

	# generate argsHelpText
	execName="${0##*/}"
	if [ "$execName" = "bash" ]; then
		execName="stdin"
	fi

	# TODO: description can wrap around incorrectly
	local descriptionOutput=
	if [ -n "${description:-}" ]; then
		printf -v descriptionOutput "\nDescription:\n"
	fi

	oldIFS="$IFS"
	IFS=
	if [ "${#argsHelpArrayFlags[@]}" -gt 0 ]; then
		printf -v flagOutput "\nFlags:\n%s" "${argsHelpArrayFlags[*]}"

		# Since flagOutput is the last thing to print, strip any hanging newlines
		if [ "${flagOutput: -1}" = $'\n' ]; then
			flagOutput="${flagOutput::-1}"
		fi
	fi

	argumentOutput=
	if [ "${#argsHelpArrayArgs[@]}" -gt 0 ]; then
		printf -v argumentOutput "\nSubcommands:\n%s" "${argsHelpArrayArgs[*]}"
	fi

	IFS="$oldIFS"

	# shellcheck disable=SC2034
	declare -g argsHelpText="Usage:
  $execName [flags] <arguments>
${descriptionOutput}${argumentOutput}${flagOutput}"

	unset BASH_ARGS_LIB_DIR
	unset BASH_ARGS_VERSION
}

bash-args "$@"
