#!/usr/bin/env bash
eval "$GLUE_BOOTSTRAP"
bootstrap || exit

ensure.cmd 'shdoc'

util.shopt -s dotglob
util.shopt -s globstar
util.shopt -s nullglob

generated.in 'tool-shdoc'
(
	if [ -d pkg ]; then
		cd pkg || error.cd_failed
	fi

	for file in ./**/*.{sh,bash}; do
		if [[ $file == *'/.glue/'* ]]; then
			continue
		fi

		declare output="$GENERATED_DIR/$file"
		mkdir -p "${output%/*}"
		output="${output%.*}"
		output="$output.md"
		shdoc < "$file" > "$output"
	done
) || exit
generated.out

unbootstrap
