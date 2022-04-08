# shellcheck shell=bash

bash_args.util.parse_attrs() {
	local flag_attrs="$1"

	local attr_{default,subattrs,type}=
	# IFS='|' read -r attr_{default,subattrs,type} <<< "$flag_attrs" # FIXME
	IFS='|' read -r attr_default attr_subattrs attr_type <<< "$flag_attrs"

	REPLY1=$attr_default
	if [[ "$attr_subattrs" == *'bool'* ]]; then
		REPLY2='yes'
	else
		REPLY2='no'
	fi
	REPLy3=$attr_type
}

bash_args.util.check_and_attrs() {
	unset -v REPLY; REPLY=

	local subcmd_prefix="$1"
	local flag_name="$2"

	local flag_attrs="${_args[${subcmd_prefix}${flag_name}]}"
	if [ -z "$flag_attrs" ]; then
		return 1
	fi
	REPLY=$flag_attrs
}
