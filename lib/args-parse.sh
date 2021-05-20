# shellcheck shell=bash

args.parse() {
	# Maps of flags and their values, required booleans,
	# and their descriptions respectively
	declare -A argsShortMap argsRequired argsDescription

	local line
	while IFS= read -r line; do
		argsSpec+="$line\n"

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
				echo "context: $line" >&2
				die 'args: Must specify either an optional or required flag; neither were specified'
			fi

			if [ -n "$flagNameOptional" ] && [ -n "$flagNameRequired" ]; then
				echo "context: $line" >&2
				die 'args: Must specify either an optional or required flag; both were specified'
			fi

			# Set flagName, which always has a value unlike
			#flagNameOptional or flagNameRequired
			local flagName="${flagNameOptional:-"$flagNameRequired"}"
			local longFlag="${flagName%%.*}"
			local shortFlag="${flagName##*.}"
			if [ "$flagName" = "$shortFlag" ]; then shortFlag=; fi

			# Set argsRequired
			if [ -z "$flagNameRequired" ]; then
				if [ -n "$longFlag" ]; then
					argsRequired+=(["$longFlag"]="yes")
				fi

				if [ -n "$shortFlag" ]; then
					argsRequired+=(["$shortFlag"]="yes")
				fi
			fi

			# Set argsDescription
			if [ -n "$longFlag" ]; then
				argsDescription+=(["$longFlag"]="$flagDescription")
			fi

			if [ -n "$shortFlag" ]; then
				argsDescription+=(["$shortFlag"]="$flagDescription")
			fi

			# Set argsShortMap
			if [ -n "$shortFlag" ]; then
				if [ -n "$longFlag" ]; then
					argsShortMap+=(["-$shortFlag"]="$longFlag")
				fi
			fi

			# Set args
			# Only set shortFlag if longFlag isn't defined
			if [ -n "$longFlag" ]; then
				args+=(["$longFlag"]="$flagValueDefault")
			elif [ -n "$shortFlag" ]; then
				args+=(["$shortFlag"]="$flagValueDefault")
			else
				echo "context: $line" >&2
				die "args: Neither a short flag or a long flag were specified"
			fi
		elif [ "$type" = "@arg" ]; then
			:
		else
			echo "context: $line" >&2
			die "args: Pragma must be either @flag or @arg"
		fi
	done

	# Parse the arguments, either 'read'ing or 'set'ing the values
	local -a nonFlagArgs
	# shellcheck disable=SC1007
	local arg= previousArg= forAction=read
	# shellcheck disable=SC2209,SC2192
	for arg; do
		echo "LOOP: $arg: $previousArg: $forAction" >&3
		case "$forAction" in
		read)
			case "$arg" in
				-*)
					previousArg="$arg"
					forAction=write
					continue
					;;
				*)
					nonFlagArgs+=("$arg")
					continue
					;;
			esac
			;;
		write)
			case "$arg" in
				# The previous flag was specified, but doesn't have
				# a value. Save the previous flag, and read the current
			-*)
				if [ -n "$flagNameRequired" ]; then
					die "Flag '$previousArg' is required as it's marked as required"
				else
					args+=(["$previousArg"]=)
					previousArg="$arg"
					continue
				fi
				;;

				# Read in new value
			*)
				# If previous value is long
				# previousArg="${previousArg/--/-}"
				# previousArg="${previousArg#-}"

				case "$previousArg" in
				--*)
					args+=(["$previousArg"]="$arg")
					;;
				-*)
					local currentLongValue="${argsShortMap["$arg"]}"
					args+=(["$currentLongValue"]="$arg")
					;;
				*)
					# TODO
					die 'This is not supposed to happen'
					;;
				esac

				forAction=read
				continue
			esac
			;;
		esac
	done

	echo --- >&3
	local key value
	for key in "${!args[@]}"; do
		value="${args["$key"]}"

		echo "$key: $value" >&3
	done

	if [ "$forAction" = 'write' ]; then
		# and if 'required'
		# die "args: No value found for flag '$arg:-'"
		:
	fi



}
