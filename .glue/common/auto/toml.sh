#!/usr/bin/env bash

# TODO: own file

# @description Get a particular key of a toml file
#
# @arg $1 value of key to store in $REPLY
# @arg $2 file to parse
toml.get_key() {
	local theirKey="$1"
	local file="$2"

	REPLY=
	while IFS= read -r line; do
		if [ "${line::1}" = '#' ]; then
			continue
		fi

		if [ -z "$line" ]; then
			continue
		fi

		shopt -s extglob

		key="${line%%=*}"
		key=${key##+( )}
		key=${key%%+( )}

		value="${line##*=}"
		value=${value##+( )}
		value=${value%%+( )}

		# hack to strip quotation marks
		# TODO: printf %q and only do one strip
		value="${value/#\'/}"
		value="${value/#\"/}"
		value="${value/%\"/}"
		value="${value/%\'/}"


		if [ "$key" = "$theirKey" ]; then
			REPLY="$value"
			break
		fi

	done < "$file"
}
