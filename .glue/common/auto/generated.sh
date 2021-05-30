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

	# TODO: clean up print
	echo "-- generated.in: '$GENERATED_DIR'"
}

generated.out() {
	echo "-- generated.out '$GENERATED_DIR'"

	cd "$GLUE_WD" || error.cd_failed
}
