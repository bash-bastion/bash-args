#!/usr/bin/env bats
set -Eeuo pipefail

@test "correct argsRawSpec value" {
	declare -A args=()
	declare argsRawSpec=

	source bash-args parse "--port" "3005" -- one two <<-'EOF'
	@flag [port] {3000} - The port to open on
	EOF

	local value=$'@flag [port] {3000} - The port to open on\n'
	[[ "$argsRawSpec" = "$value" ]]
}
