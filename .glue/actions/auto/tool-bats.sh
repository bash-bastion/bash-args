#!/usr/bin/env bash
eval "$GLUE_BOOTSTRAP"
bootstrap || exit

ensure.cmd 'bats'

unset main
main() {
	local -a dirs=()
	if [ -d pkg ]; then
		cd pkg || error.cd_failed
		dirs=(../test ../tests)
	else
		dirs=(test tests)
	fi

	for dir in "${dirs[@]}"; do
		[[ -d $dir ]] || continue

		bats --recursive --output "." "$dir"
	done
}

main "$@"
unbootstrap
