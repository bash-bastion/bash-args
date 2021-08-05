#!/usr/bin/env bats
set -Eeuo pipefail

@test "longOption with value" {
	declare -A args=()

	source bash-args parse --port 3005 <<-'EOF'
	@flag [port] {3000} - The port to open on
	EOF

	[[ ${args[port]} == 3005 ]]
	[[ ! -v 'args[--port]' ]]
	[[ ! -v 'args[-port]' ]]
}

@test "shortOption with value" {
	declare -A args=()

	source bash-args parse -p 3005 <<-'EOF'
	@flag [.p] {3000} - The port to open on
	EOF

	[[ ${args[p]} == 3005 ]]
	[[ ! -v 'args[-p]' ]]
}

@test "longOption and shortOption with longOption value" {
	declare -A args=()

	source bash-args parse --port 3005 <<-'EOF'
	@flag [port.p] {3000} - The port to open on
	EOF

	[[ ${args[p]} == 3005 ]]
	[[ ${args[port]} == 3005 ]]
	[[ ! -v 'args[--port]' ]]
	[[ ! -v 'args[-port]' ]]
	[[ ! -v 'args[-p]' ]]
}

@test "longOption and shortOption with shortOption value" {
	declare -A args=()

	source bash-args parse -p 3005 <<-'EOF'
	@flag [port.p] {3000} - The port to open on
	EOF

	[[ ${args[p]} == 3005 ]]
	[[ ${args[port]} == 3005 ]]
	[[ ! -v 'args[--port]' ]]
	[[ ! -v 'args[-port]' ]]
	[[ ! -v 'args[-p]' ]]
}

# ------------------- without values -------------------
@test "longOption no value" {
	skip 'Issue #6'

	declare -A args=()

	source bash-args parse --version <<-'EOF'
	@flag [version.v] - The port to open on
	EOF

	[[ ${args[version]} == yes ]]
	[[ ${args[v]} == yes ]]
}

@test "longOption and default" {
	declare -A args=()

	source bash-args parse <<-'EOF'
	@flag [port] {3000} - The port to open on
	EOF

	[[ ${args[port]} == 3000 ]]
}

@test "shortOption and default" {
	declare -A args=()

	source bash-args parse <<-'EOF'
	@flag [.p] {3000} - The port to open on
	EOF

	[[ ${args[p]} == 3000 ]]
}

@test "longOption and shortOption" {
	declare -A args=()

	source bash-args parse <<-'EOF'
	@flag [port.p] {3000} - The port to open on
	EOF

	[[ ${args[port]} == 3000 ]]
	[[ ${args[p]} == 3000 ]]
}

# -------- ensure failure on invalid conditions --------

@test "properly fails on not finishing required arguments" {
	declare -A args=()

	! (
		source bash-args parse --port --something nother <<-'EOF'
		@flag <port> {} - The port to open on
		EOF
	)
}

@test "properly doesn't fails on not finishing required boolean arguments" {
	declare -A args=()

	(
		source bash-args parse --port --something nother <<-'EOF'
		@flag <port> - The port to open on
		@flag <something> - something
		EOF
	)
}

@test "properly fail if value contains hypthens" {
	declare -A args=()

	! (
		source bash-args parse --port - <<-'EOF'
		@flag [port] {} - The port to open on
		EOF
	)
}

@test "properly does not fail if hyphen on boolean flag" {
	declare -A args=()

	(
		source bash-args parse --port - <<-'EOF'
		@flag [port] - The port to open on
		EOF
	)
}

@test "properly fail if required flag not given" {
	declare -A args=()

	! (
		source bash-args parse <<-'EOF'
		@flag <port> The port to open on
		EOF
	)
}
