#!/usr/bin/env bash

generated.in() {
	local dir="$1"
	ensure.nonZero 'dir' "$dir"

	# shellcheck disable=SC2034
	declare -g GENERATED_DIR="$GLUE_WD/.glue/generated/$dir"

	if [ -d "$GLUE_WD/.glue/generated/$dir" ]; then
		rm -rf "$GLUE_WD/.glue/generated/$dir"
	fi
	mkdir  "$GLUE_WD/.glue/generated/$dir"


	shopt -q extglob
	local extGlobExitStatus=$?
	shopt -s extglob

	if [[ "${LANG,,?}" == *utf?(-)8 ]]; then
		echo "■■■■■■ 🢂  IN GENERATED: '$GENERATED_DIR'"
	else
		echo "=> IN GENERATED: '$GENERATED_DIR'"
	fi

	if (( extGlobExitStatus != 0 )); then
		shopt -u extglob
	fi
}

generated.out() {
	if [[ "${LANG,,?}" == *utf?(-)8 ]]; then
		echo "■■■■■■ 🢂  OUT GENERATED: '$GENERATED_DIR'"
	else
		echo "=> OUT GENERATED: '$GENERATED_DIR'"
	fi

	cd "$GLUE_WD" || error.cd_failed
}
