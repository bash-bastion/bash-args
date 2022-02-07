# shellcheck shell=bash

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
			Show version of 'bash-args'

		--help
			Show help
		EOF
		return
		;;
	-v|--version)
		cat <<-"EOF"
			Version: # TODO
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
	local -a args_command_boolean_flags=()

	# Array containing all arguments for help menu
	local -a args_help_array_args=()

	# Array containing all flags for help menu
	local -a args_help_array_flags=()

	# Array containing all flags
	local -a args_all_flags=()

	local line
	while IFS= read -r line; do
		argsRawSpec+="$line"$'\n'

		if [ -z "$line" ]; then
			continue
		fi

		local type="${line%% *}"
		if [ "$type" = "@flag" ]; then
			# Parse line
			# TODO: condence flag_name_optional and flag_name_required with extglob features
			local flag_name_optional="${line##*[}"; flag_name_optional="${flag_name_optional%%]*}"
			local flag_name_required="${line##*<}"; flag_name_required="${flag_name_required%%>*}"
			local flag_name_default="${line##*\{}"; flag_name_default="${flag_name_default%%\}*}"
			local flag_description="${line##* -}"

			# TODO: nullglob
			# Ensure each variable is blank if parsing did not find anything. This corrects for parameter
			# expansion behavior, since no modifications to the original line if a match was not found
			if [ "$line" = "$flag_name_optional" ]; then flag_name_optional=; fi
			if [ "$line" = "$flag_name_required" ]; then flag_name_required=; fi
			if [ "$line" = "$flag_name_default" ]; then
				# We must differentiate between specifying in '{}' (a flag that defaults to empty), and not
				# specifying '{}'. If '{}' is specified (default empty flag), this variable is unset;
				# otherwise, if '{}' is not specified at all, the variable is unset. If unset, we expect
				# the flag to be ONLY a boolean flag, and expect no values to follow it (only more flags)
				unset flag_name_default
			fi
			if [ "$line" = "$flag_description" ]; then flag_description=; fi

			# Sanity checks
			if [ -z "$flag_name_optional" ] && [ -z "$flag_name_required" ]; then
				bash_args.util.die 'bash-args: Must specify either an optional or required flag; neither were specified'
				return
			fi

			if [ -n "$flag_name_optional" ] && [ -n "$flag_name_required" ]; then
				bash_args.util.die 'bash-args: Must specify either an optional or required flag; both were specified'
				return
			fi

			# Set 'long_flag' and 'short_flag', using 'flag_name' as an intermediary value so it works
			# whether the line specifies either an optional or a required argument
			local flag_name="${flag_name_optional:-"$flag_name_required"}"
			local long_flag="${flag_name%%.*}"
			local short_flag="${flag_name##*.}"

			# Like above, we account for the behavior of parameter expansion, ensuring 'short_flag' is empty
			# if it was not provided (i.e, long_flag was only provided). We do not do this
			# for 'long_flag' because if it was not provided (i.e., only 'short_flag' was provided), the
			# dot is still required to be there (to differentiate it from a long flag), so the parameter
			# expansion is guaranteed to work
			if [ "$flag_name" = "$short_flag" ]; then short_flag=; fi

			# Append to args_command_boolean_flags, if applicable, to be used later for enduring
			# a flag is not supposed to have any value specifier following it
			if [[ ! -v flag_name_default ]]; then
				if [ -n "$long_flag" ]; then
					args_command_boolean_flags+=("$long_flag")
				fi

				if [ -n "$short_flag" ]; then
					args_command_boolean_flags+=("$short_flag")
				fi
			fi

			# Append to args_all_flags, if applicable, to be used later for ensuring
			# a particular flag was actually specified in the stdin spec
			if [ -n "$long_flag" ]; then
				args_all_flags+=("--$long_flag")
			fi

			if [ -n "$short_flag" ]; then
				args_all_flags+=("-$short_flag")
			fi

			# TODO: rename
			# Set the 'current_flag' or flags for pretty printing the supplied
			# flags (short and long) for the current line
			local current_flag=
			if [[ -n "$long_flag" && -n "$short_flag" ]]; then
				current_flag="--$long_flag or -$short_flag"
			elif [ -n "$long_flag" ]; then
				current_flag="--$long_flag"
			elif [ -n "$short_flag" ]; then
				current_flag="-$short_flag"
			fi

			# shellcheck disable=SC1007
			local arg= flag_was_found=no did_immediate_break=no
			for arg; do
				if [ "$arg" = "--" ]; then
					break
				fi

				if [ "$flag_was_found" = yes ]; then
					did_immediate_break=yes
					break
				fi

				if [ "$arg" = "--$long_flag" ]; then
					flag_was_found=yes
				elif [ "$arg" = "-$short_flag" ]; then
					flag_was_found=yes
				fi
			done
			local flag_value_cli="$arg"

			# Debug
			if [[ -v DEBUG_BASH_ARGS ]]; then
				# Ensure the third file descriptor is valid for writing. We use 3 because
				# it's printed to the terminal when testing with Bats using the TAP formatter
				if ! : >&3; then
					exec 3>&1
				fi 2>/dev/null

				cat >&3 <<-EOF
				flag_name_optional: $flag_name_optional
				flag_name_required: $flag_name_required
				flag_name_default: ${flag_name_default-"NOT SET"}
				flag_description: $flag_description

				flag_name: $flag_name
				long_flag: $long_flag
				short_flag: $short_flag

				args_command_boolean_flags: ${args_command_boolean_flags[@]}
				args_all_flags: ${args_all_flags[@]}
				current_flag: $current_flag
				flag_value_cli: $flag_value_cli
				EOF
			fi

			# If the flag name is required, we exit a failure if it's not there
			if [ -n "$flag_name_required" ]; then
				# If we did not set flag_was_found=yes, it means it did not find
				# the flag. So, if the flag is <required>, we fail right away
				if [ "$flag_was_found" = no ]; then
					bash_args.util.die "bash-args: You must supply the flag '$current_flag' with a value"
					return
				fi

				# If we were supposed to do an immediate break, but didn't actually
				# do it, it means we are on the last argument and there is no value
				if [ "$flag_was_found" = yes ] && [ "$did_immediate_break" = no ]; then
					bash_args.util.die "bash-args: No value found for flag '$current_flag'"
					return
				fi
			fi

			# Set the default for the current flag. If there is no default,
			# it is just an empty assignment. If flag_name_default is unset,
			# it means the flag is a boolean so we set the default to 'no'
			if [[ -v flag_name_default ]]; then
				if [ -n "$long_flag" ]; then
					args+=(["$long_flag"]="${flag_name_default:-}")
				fi

				if [ -n "$short_flag" ]; then
					args+=(["$short_flag"]="${flag_name_default:-}")
				fi
			else
				if [ -n "$long_flag" ]; then
					args+=(["$long_flag"]=no)
				fi

				if [ -n "$short_flag" ]; then
					args+=(["$short_flag"]=no)
				fi
			fi

			# There is a flag with a possible value
			# the did_immediate_break check ensures that the value of "$arg" isn't
			# the same as the last element (which is the flag option itself)
			if [ "$flag_was_found" = yes ] && [ "$did_immediate_break" = yes ]; then
				case "$flag_value_cli" in
					-*)
						if [[ -v flag_name_default ]]; then
							bash_args.util.die "bash-args: You must supply a value for '$current_flag'"
							return
						fi
						;;
					*)
						# The user-supplied flag is valid, override the default
						if [[ -v flag_name_default ]]; then
							if [ -n "$long_flag" ]; then
								args+=(["$long_flag"]="$flag_value_cli")
							fi

							if [ -n "$short_flag" ]; then
								args+=(["$short_flag"]="$flag_value_cli")
							fi
						else
							if [ -n "$long_flag" ]; then
								args+=(["$long_flag"]=yes)
							fi

							if [ -n "$short_flag" ]; then
								args+=(["$short_flag"]=yes)
							fi
						fi
				esac
			# This is the last element of "$@". It only applies to boolean options
			elif [ "$flag_was_found" = yes ] && [ "$did_immediate_break" = no ]; then
				if [ -n "$long_flag" ]; then
					args+=(["$long_flag"]=yes)
				fi

				if [ -n "$short_flag" ]; then
					args+=(["$short_flag"]=yes)
				fi
			fi

			# Construct 'argsHelpText'

			# shellcheck disable=SC1007
			local flag_name_combo= flag_description=

			# Option
			if [[ -n "$long_flag" && -n "$short_flag" ]]; then
				flag_name_combo="$short_flag, $long_flag"
			elif [ -n "$short_flag" ]; then
				flag_name_combo="$short_flag"
			elif [ -n "$long_flag" ]; then
				flag_name_combo="$long_flag"
			fi

			if [ -n "$flag_name_required" ]; then
				# flag_name_combo="$flag_name_combo <>"

				if [ -n "$flag_description" ]; then
					flag_description="(Required) $flag_description"
				else
					flag_description="(Required)"
				fi
			fi

			if [[ -v flag_name_default ]]; then
				if [ -n "$flag_description" ]; then
					flag_description="(Default: $flag_name_default) $flag_description"
				else
					flag_description="(Default: $flag_name_default)"
				fi
			fi

			# TODO: description can wrap around incorrectly
			flag_name_combo="  ${flag_name_combo}"
			if [ "${#flag_name_combo}" -lt 20 ]; then
				printf -v flag_name_combo '%-20s' "$flag_name_combo"
				args_help_array_flags+=("${flag_name_combo}$flag_description"$'\n')
			else
				args_help_array_flags+=("${flag_name_combo}\n$flag_description"$'\n')
			fi

		elif [ "$type" = "@arg" ]; then
			local name="${line#* }"; name="${name%% *}"
			local argDescription="${line##* - }"

			# for argsHelpText
			printf -v name '%-20s' "  $name"
			args_help_array_args+=("${name}${argDescription}"$'\n')
		else
			bash_args.util.die "bash-args: Pragma must be either @flag or @arg. Received: '$type'"
			return
		fi
	done

	# Construct 'argsCommands'. Note that this ONLY provides accurate results if we check and exit the
	# program on flags that are not recognized
	local args_command_mode=append
	for arg; do
		if [ "$args_command_mode" = skip ]; then
			args_command_mode=append
			continue
		fi

		case "$arg" in
			-*)
				# We only skip the next argument if the current
				# argument is NOT a boolean argument
				local should_skip=yes
				for boolean_arg in "${args_command_boolean_flags[@]}"; do
					local cut_arg="${arg/#-/}"
					cut_arg="${cut_arg/#-/}"

					if [ "$boolean_arg" = "$cut_arg" ]; then
						should_skip=no
						break
					fi
				done

				if [ "$should_skip" = yes ]; then
					args_command_mode=skip
				fi
				;;
			*)
				if [ "$args_command_mode" = append ]; then
					argsCommands+=("$arg")
				fi
		esac
	done

	# use args_all_flags to ensure no invalid arguments
	for arg; do
		case "$arg" in
		-) ;;
		--) break ;;
		-*)
			local is_valid_flag=no
			for flag in "${args_all_flags[@]}"; do
				if [ "$flag" = "$arg" ]; then
					is_valid_flag=yes
					break
				fi
			done

			if [ "$is_valid_flag" = no ]; then
				bash_args.util.die "bash-args: Flag '$arg' is not accepted"
				return
			fi
		esac
	done

	# generate argsHelpText
	exec_name="${0##*/}"
	if [ "$exec_name" = "bash" ]; then
		exec_name="stdin"
	fi

	# TODO: description can wrap around incorrectly
	local description_output=
	if [ -n "${description:-}" ]; then
		printf -v description_output "\nDescription:\n"
	fi

	oldIFS="$IFS"
	IFS=
	if [ "${#args_help_array_flags[@]}" -gt 0 ]; then
		printf -v flagOutput "\nFlags:\n%s" "${args_help_array_flags[*]}"

		# Since flagOutput is the last thing to print, strip any hanging newlines
		if [ "${flagOutput: -1}" = $'\n' ]; then
			flagOutput="${flagOutput::-1}"
		fi
	fi

	argument_output=
	if [ "${#args_help_array_args[@]}" -gt 0 ]; then
		printf -v argument_output "\nSubcommands:\n%s" "${args_help_array_args[*]}"
	fi

	IFS="$oldIFS"

	# shellcheck disable=SC2034
	declare -g argsHelpText="Usage:
  $exec_name [flags] <arguments>
${description_output}${argument_output}${flagOutput}"

	unset BASH_ARGS_LIB_DIR
	unset BASH_ARGS_VERSION
}
