#!/usr/bin/env bash
eval "$GLUE_BOOTSTRAP"
bootstrap || exit

unset task
task() {
	declare -g RELEASE_STATUS=dry
	for arg; do
		case "$arg" in
			--wet)
				# shellcheck disable=SC2034
				RELEASE_STATUS=wet
		esac
	done

	ensure.cmd 'git'
	ensure.cmd 'gh'
	ensure.file 'glue-auto.toml'

	if is.dry_release; then
		log.info "Running pre-release process in dry mode"
	else
		ensure.confirm_wet_release
	fi

	# Perform build
	# TODO: perform build on commit hook etc.
	util.get_command 'Bash.build.sh'
	source "$REPLY"

	# Ensure tests pass
	util.get_command 'Bash.test.sh'
	source "$REPLY"

	# Build docs
	util.get_command 'Bash.docs.sh'
	source "$REPLY"

	ensure.git_working_tree_clean
	ensure.git_common_history

	local newVersion=
	if is.dry_release; then
		toml.get_key 'version' 'glue-auto.toml'
		newVersion="$REPLY"

		ensure.nonZero 'newVersion' "$newVersion"
	else
		toml.get_key 'version' 'glue-auto.toml'
		util.prompt_new_version "$REPLY"
		newVersion="$REPLY"

		ensure.nonZero 'newVersion' "$newVersion"
		ensure.version_is_only_major_minor_patch "$newVersion"
		ensure.git_version_tag_validity "$newVersion"
	fi

	util.general_version_bump "$newVersion"

	ensure.git_working_tree_dirty

	if is.dry_release; then
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

	# glue useAction(result-pacman-package.sh)
	util.get_action 'result-pacman-package.sh'
	source "$REPLY"
}

task "$@"
unset task

unbootstrap
