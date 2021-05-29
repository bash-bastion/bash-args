#!/usr/bin/env bash
eval "$GLUE_BOOTSTRAP"
bootstrap || exit

ensure.cmd 'shdoc'

util.shopt -s dotglob
util.shopt -s globstar
util.shopt -s nullglob

declare outDir=".glue/generated/tool-shdoc"
rm -rf "$outDir"
for file in ./**/*.{sh,bash}; do
	if [[ $file == *'/.glue/'* ]]; then
		continue
	fi

	declare output="$outDir/$file"
	mkdir -p "${output%/*}"
	output="${output%.*}"
	output="$output.md"
	shdoc < "$file" > "$output"
done

unbootstrap
