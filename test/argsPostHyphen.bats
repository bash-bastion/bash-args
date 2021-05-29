#!/usr/bin/env bash
set -Eeuo pipefail

@test "append to post argsPostHyphen if set" {
	declare -A args=()
	declare -a argsPostHyphen=()

	source ./bin/args.parse "--port" "3005" -- one two <<-'EOF'
	@flag [port] {3000} - The port to open on
	EOF

	[[ "${#argsPostHyphen[@]}" = 2 ]]
	[[ "${argsPostHyphen[0]}" = one ]]
	[[ "${argsPostHyphen[1]}" = two ]]
}
