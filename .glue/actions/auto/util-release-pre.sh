#!/usr/bin/env bash
# eval "$GLUE_BOOTSTRAP"
# bootstrap || exit

# @file util-release-pre.sh
# @brief Steps to perform before specialized version bumping
# @description Before the release is made, this ensures there
#   are no changes in the working directory, and from the version
#   in 'glue-auto.toml', increments the version. This does not handle
#   anything language specific, so this is usually called along with
#   'util-release-post.sh', and any other files that need version bumping
#   is performed in the interum

unset main
main() {
	ensure.cmd 'git'
	ensure.file 'glue-auto.toml'

	# Ensure working tree not dirty
	if [ -n "$(git status --porcelain)" ]; then
		die 'Working tree still dirty. Please commit all changes before making a release'
	fi

	# Ensure we can push new version and its tags changes without --force-lease
	if ! git merge-base --is-ancestor origin/main main; then
		# main NOT is the same or has new additional commits on top of origin/main"
		die "Detected that your 'main' branch and it's remote have diverged. Won't initiate release process until histories are shared"
	fi

	# Get current version
	toml.get_key version glue-auto.toml
	local currentVersion="$REPLY"

	# Get new version number
	# TODO: make incremenet better
	echo "Current Version: $currentVersion"
	read -rp 'New Version? ' -ei "$currentVersion"
	local newVersion="$REPLY"
	declare -g REPLY="$newVersion" # explicit

	# Ensure new version is valid (does not already exist)
	if [ -n "$(git tag -l "v$newVersion")" ]; then
		# TODO: ensure there are no tag sthat exists that are greater than it
		die 'Version already exists in a Git tag'
	fi

	sed -i -e "s|\(version[ \t]*=[ \t]*\"\).*\(\"\)|\1${newVersion}\2|g" glue-auto.toml
}

main "$@"

# unbootstrap
