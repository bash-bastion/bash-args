#!/usr/bin/env bash
eval "$GLUE_ACTIONS_BOOTSTRAP"
bootstrap || exit

ensure.cmd 'bats'

for dir in test tests; do
	[[ -d $dir ]] || continue

	bats --recursive --output "." "$dir"
done

unbootstrap
