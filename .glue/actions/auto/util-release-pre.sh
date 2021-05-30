#!/usr/bin/env bash
eval "$GLUE_BOOTSTRAP"
bootstrap || exit

# @file util-release-pre.sh
# @brief Steps to perform before specialized version bumping
# @description This does the following
# - Ensures a clean Git working tree
# - Ensures a shared history (no force pushing)
# - Update version in 'glue-auto.toml'

unset main
main() {
	ensure.cmd 'git'
	ensure.file 'glue-auto.toml'

	local -r dryStatus="$1"
	isDry() {
		# must be set to 'notDry' to not be dry.
		# Defaults to 'not dry'
		[ "$dryStatus" != "notDry" ]
	}

	if isDry; then
		log.info "Running pre-release process in dry mode"
	fi

	# Ensure working tree not dirty
	if [ -n "$(git status --porcelain)" ]; then
		if isDry; then
			local cmd="log.warn"
		else
			local cmd="die"
		fi

		"$cmd" 'Working tree still dirty. Please commit all changes before making a release'
	fi

	# Ensure we can push new version and its tags changes without --force-lease
	if ! git merge-base --is-ancestor origin/main main; then
		if isDry; then
			local cmd="log.warn"
		else
			local cmd="die"
		fi

		# main NOT is the same or has new additional commits on top of origin/main"
		"$cmd" "Detected that your 'main' branch and it's remote have diverged. Won't initiate release process until histories are shared"
	fi

	local newVersion=
	if isDry; then
		# Calculate new version based on current commit

		# glue useAction(util-get-version.sh)
		util.get_action "util-get-version.sh"
		source "$REPLY"
		newVersion="$REPLY"
	else
		# Get current version
		toml.get_key version glue-auto.toml
		local currentVersion="$REPLY"

		# Get new version number
		# TODO: make incremenet better
		echo "Current Version: $currentVersion"
		read -rp 'New Version? ' -ei "$currentVersion"
		newVersion="$REPLY"
		declare -g REPLY="$newVersion" # explicit

		# Ensure new version is valid (does not already exist)
		if [ -n "$(git tag -l "v$newVersion")" ]; then
			# TODO: ensure there are no tags that exists that are greater than it
			die 'Version already exists in a Git tag'
		fi
	fi

	sed -i -e "s|\(version[ \t]*=[ \t]*\"\).*\(\"\)|\1${newVersion}\2|g" glue-auto.toml
}

main "$@"
unset main

unbootstrap
