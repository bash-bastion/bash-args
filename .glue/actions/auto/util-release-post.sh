#!/usr/bin/env bash
eval "$GLUE_BOOTSTRAP"
bootstrap || exit

# @file util-release-post.sh
# @brief Steps to perform after specialized version bumping
# - Ensure a dirty Git working tree
# - Add bumped files to commit with version number
# - Make GitHub release

unset main
main() {
	local -r dryStatus="$1"
	local newVersion="$2"

	ensure.cmd 'git'
	ensure.cmd 'gh'

	ensure.nonZero 'newVersion' "$newVersion"

	isDry() {
		# must be set to 'notDry' to not be dry.
		# Defaults to 'not dry'
		[ "$dryStatus" != "notDry" ]
	}

	if isDry; then
		log.info "Running release process in dry mode"
	fi

	# Ensure working tree is dirty
	if [ -z "$(git status --porcelain)" ]; then
		if isDry; then
			local cmd="log.warn"
		else
			local cmd="die"
		fi

		"$cmd" 'Working tree is not dirty. Cannot make a release if versions have not been bumped in their respective files'
	fi

	# Local Release
	if isDry; then
		log.info "Skipping Git taging and artifact release"
	else
		git add -A
		git commit -m "chore(release): v$newVersion"
		git tag -a "v$newVersion" -m "Release $newVersion" HEAD
		git push --follow-tags origin HEAD

		local -a args=()
		if [ -f CHANGELOG.md ]; then
			args+=("-F" "CHANGELOG.md")
		elif [ -f changelog.md ]; then
			args+=("-F" "changelog.md")
		else
			# '-F' is required for non-interactivity
			args+=("-F" "")
			log.warn 'CHANGELOG.md file not found. Creating empty notes file for release'
		fi

		# Remote Release
		gh release create "v$newVersion" --target main --title "v$newVersion" "${args[@]}"
	fi
}

main "$@"
unset main

unbootstrap
