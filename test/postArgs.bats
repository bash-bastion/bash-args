#!/usr/bin/env bash
set -Eo pipefail

source ../args.sh

@test "append to post postArgs if set" {
	declare -A postArgs=()

	arguments "--port" "3005" -- one two <<-'EOF'
	@flag [port] {3000} - The port to open on
	EOF

	[[ "${#postArgs[@]}" = 2 ]]
	[[ "${postArgs[1]}" = one ]]
	[[ "${postArgs[2]}" = two ]]
}

@test "do not append to post postArgs if not set" {
	arguments "--port" "3005" -- one two <<-'EOF'
	@flag [port] {3000} - The port to open on
	EOF

	[[ ! -v 'postArgs' ]]
}
