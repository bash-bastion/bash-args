# shellcheck shell=bash

# TODO: ensure that the number of arguments is divisible by 4 (minus subcommands)
barg.define_flags() {
	# Prefix that is used when storing each flag in an associative array. For example,
	# with a subcmd of 'subcmd', then 'other', the prefix is 'subcmd__other__'
	local subcmd_prefix=

	local i=
	for ((i=1; i < $# + 1;)); do
		local arg="${!i}"

		# The end of a subcmd was specified
		if [ "$arg" = 'END' ]; then
			subcmd_prefix=${subcmd_prefix%__}
			subcmd_prefix=${subcmd_prefix%__*}
			subcmd_prefix+='__'

			i=$((i+1))
			continue
		# The start of a subcmd was specified
		elif [ -n "$arg" ] && [ "${arg::1}" != '-' ]; then
			local subcmd="$arg"
			subcmd_prefix+="${subcmd}__"

			printf '%s\n' "subcmd: $subcmd"
			_args["${subcmd_prefix}${flag_long}"]="a"

			i=$((i+1))
			continue
		fi

		# A 'normal' pattern of 4 arguments that describes a flag
		local i_flag_short=$((i+1))
		local i_flag_attrs=$((i+2))
		local i_flag_desc=$((i+3))
		local flag_long="$arg"
		local flag_short="${!i_flag_short}"
		local flag_attrs="${!i_flag_attrs}"
		local flag_desc="${!i_flag_desc}"
		unset -v i_flag_{short,options,desc}

		# Argument specification
		# --four -f
		# --four ''
		# '' -four

		if [ -n "$flag_long" ]; then
			if [[ $flag_long != --?* ]]; then
				bash_args.print.error "Long flag must start with double hyphens and have something after ($flag_long)"
				return 1
			fi

			# --four -f
			if [ -n "$flag_short" ]; then
				if [[ $flag_short != -[^-] ]]; then
					bash_args.print.error "The short flag paired with a long flag must have only one character  ($flag_short)"
					exit 1
				fi

				printf "%s\n" "-- A: $flag_long:$flag_short"
				_args["${subcmd_prefix}${flag_long}"]="$flag_attrs|$flag_desc"
				_args["${subcmd_prefix}${flag_short}"]="$flag_attrs|$flag_desc"
				_args_maplong["${flag_long}"]="$flag_short"
				_args_mapshort["${flag_short}"]="$flag_long"
				_args['__order__']+="|${subcmd_prefix}${flag_long}"
			# --four ''
			else
				printf "%s\n" "-- B: $flag_long:$flag_short"
				_args["${subcmd_prefix}${flag_long}"]="$flag_attrs|$flag_desc"
				_args['__order__']+="|${subcmd_prefix}${flag_long}"
			fi
		# '' -four
		else
			if [[ $flag_short != -[^-]* ]]; then
				bash_args.print.error "Short flag must start with single hyphen and have something after  ($flag_short)"
				return 1
			fi

			printf "%s\n" "-- C: $flag_long:$flag_short"
			_args["${subcmd_prefix}${flag_short}"]="$flag_attrs|$flag_desc"
			_args['__order__']+="|${subcmd_prefix}${flag_short}"
		fi

		i=$((i+4))
	done; unset -v i arg
}

barg.parse_flags() {
	local subcmd_prefix=

	printf '%s\n' '_ARGS'
	local key= value=
	for key in "${!_args[@]}"; do
		value="${_args[$key]}"
		printf '  %s\n' "$key: $value"
	done; unset -v key value

	# shellcheck disable=SC1007
	local i=
	for ((i=1; i < $# + 1; ++i)); do
		local ii=$((i+1))
		local arg="${!i}"
		local arg_next="${!ii}"
		unset -v ii

		# shellcheck disable=SC1007
		local flag_name= flag_value=

		# Arg must either be one of
		# --color auto
		# --color=auto
		# --no-color

		# -color auto
		# -color=auto
		# -no-color

		# -r
		# -rc10
		# subcmd

		# for a particular point in the hierarchy, if there are child subcommands, only allow
		# non-flag arguments that match the subcommands. however, if there are no child subcommands,
		# then add it to the "non flag arguments" array

		# 'flag_name' is similar to 'flag_long' or 'flag_short'

		if [[ $arg == '--'* ]]; then
			if [[ $arg == *=* ]]; then
				IFS='=' read -r flag_name flag_value <<< "$arg"
			else
				flag_name="$arg"

				if ! bash_args.check_and_attrs "$subcmd_prefix" "$flag_name"; then
					return 1 # Error already printed
				fi

				local flag_attrs="${_args[${subcmd_prefix}${flag_name}]}"
				bash_args.util.parse_attrs "$flag_attrs"
				local attr_default="$REPLY1"
				local attr_boolflag="$REPLY2"
				local attr_type="$REPLY3"

				if ((i == $#)) && [ "$attr_boolflag" = 'no' ]; then
					echo must pass value
					exit 1
				fi

				# Before we get the next value, we check (above) if there is actually a next value
				flag_value="$arg_next"
				((++i))
			fi

			:
		elif [[ $arg = '-'* ]]; then
			:
		else
			subcmd_prefix+="${arg}__"
			:
		fi

	done; unset -v i subcmd flag
}

