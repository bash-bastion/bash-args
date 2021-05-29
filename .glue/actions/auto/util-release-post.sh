#!/usr/bin/env bash
# eval "$GLUE_BOOTSTRAP"
# bootstrap || exit

# @file util-release-post.sh
# @brief Steps to perform after specialized version bumping

unset main
main() {
	local newVersion="$1"
	ensure.nonZero 'newVersion' "$newVersion"

	ensure.cmd 'git'
	ensure.cmd 'gh'

	# Ensure working tree is dirty
	if [ -z "$(git status --porcelain)" ]; then
		die 'Working tree is not dirty. Cannot make a release if versions have not been bumped in their respective files'
	fi

	# Local Release
	git add -A
	git commit -m "chore(release): v$newVersion"
	git tag -a "v$newVersion" -m "Release $newVersion" HEAD
	git push --follow-tags origin HEAD

	local -a args=()
	if [ -f CHANGELOG.md ]; then
		args+=("--notes-file" "CHANGELOG.md")
	elif [ -f changelog.md ]; then
		args+=("--notes-file" "changelog.md")
	else
		log.warn 'CHANGELOG.md file not found. Not creating a notes file for release'
	fi

	# Remote Release
	toml.get_key name glue.toml
	local projectName="${REPLY:-Release}"
	gh release create "v$newVersion" --target main --title "$projectName v$newVersion" "${args[@]}"
}

main "$@"

# unbootstrap
