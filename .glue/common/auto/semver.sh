#!/usr/bin/env bash
# shellcheck disable=SC1007,SC2209

# TODO: move to repo
debug() {
	if [[ -v DEBUG ]]; then
		echo "mode: $mode"
		echo "char: $char"
		echo
	fi
}

# @description Parse a semver version blurb into 'major', 'minor', 'patch',
# 'preRelease', and 'build' variables
#
# @arg $1 semver version blurb
semver.parse() {
	declare -g major= minor= patch= preRelease= build=
	local mode=major char=
	while IFS= read -rn1 char; do
		debug

		case "$mode" in
		major)
			if [[ $char = . ]]; then
				mode=minor
			else
				major+="$char"
			fi
			;;
		minor)
			if [[ $char = . ]]; then
				mode=patch
			else
				minor+="$char"
			fi
			;;
		patch)
			if [[ $char = - ]]; then
				mode=preRelease
			elif [[ $char = + ]]; then
				mode=build
			else
				patch+="$char"
			fi
			;;
		preRelease)
			if [[ $char = + ]]; then
				mode=build
			else
				preRelease+="$char"
			fi
			;;
		build)
			build+="$char"
			;;
		esac
	done <<< "$1"
}
