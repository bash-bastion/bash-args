#!/usr/bin/env bash
eval "$GLUE_BOOTSTRAP"
bootstrap

action() {
	ensure.cmd 'shdoc'

	util.shopt -s dotglob
	util.shopt -s globstar
	util.shopt -s nullglob

	local exitCode=0

	bootstrap.generated 'tool-shdoc'; (
		ensure.cd 'pkg'

		local exitCode=0

		for file in ./**/*.{sh,bash}; do
			local outputFile="$GENERATED_DIR/$file"
			mkdir -p "${outputFile%/*}"
			outputFile="${outputFile%.*}"
			outputFile="$outputFile.md"
			if shdoc < "$file" > "$outputFile"; then : else
				# TODO: set exitCode on all
				if is.wet_release; then
					exitCode=$?
				fi
			fi

			if [ "$(stat -c "%s" "$outputFile")" -le 5 ]; then
				rm "$outputFile"
				rmdir -p --ignore-fail-on-non-empty "$GENERATED_DIR"
			fi

			mkdir -p "$GENERATED_DIR"
		done

		return "$exitCode"
	); exitCode=$?; unbootstrap.generated

	REPLY="$exitCode"
}

action "$@"
unbootstrap
