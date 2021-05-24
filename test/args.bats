#!/usr/bin/env bats
set -Eeuo pipefail

source ./bin/args-init

@test "longOption with value" {
	declare -A args=()

	args.parse "--port" "3005" <<-'EOF'
	@flag [port] {3000} - The port to open on
	EOF

	[[ ${args[port]} == 3005 ]]
	[[ ! -v 'args[--port]' ]]
	[[ ! -v 'args[-port]' ]]
}

@test "shortOption with value" {
	declare -A args=()

	args.parse "-p" "3005" <<-'EOF'
	@flag [.p] {3000} - The port to open on
	EOF

	[[ ${args[p]} == 3005 ]]
	[[ ! -v 'args[-p]' ]]
}

@test "longOption and shortOption with longOption value" {
	declare -A args=()

	args.parse "--port" "3005" <<-'EOF'
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

	args.parse "-p" "3005" <<-'EOF'
	@flag [port.p] {3000} - The port to open on
	EOF

	[[ ${args[p]} == 3005 ]]
	[[ ${args[port]} == 3005 ]]
	[[ ! -v 'args[--port]' ]]
	[[ ! -v 'args[-port]' ]]
	[[ ! -v 'args[-p]' ]]
}

# # ------------------- without values -------------------

@test "longOption and default" {
	declare -A args=()

	args.parse - <<-'EOF'
	@flag [port] {3000} - The port to open on
	EOF

	[[ ${args[port]} == 3000 ]]
}

@test "shortOption and default" {
	declare -A args=()

	args.parse <<-'EOF'
	@flag [.p] {3000} - The port to open on
	EOF

	[[ ${args[p]} == 3000 ]]
}

@test "longOption and shortOption" {
	declare -A args=()

	args.parse <<-'EOF'
	@flag [port.p] {3000} - The port to open on
	EOF

	[[ ${args[port]} == 3000 ]]
	[[ ${args[p]} == 3000 ]]
}

# -------- ensure failure on invalid conditions --------

@test "properly fails on not finishing required arguments" {
	declare -A args=()

	! (
		args.parse --port --something nother <<-'EOF'
		@flag <port> - The port to open on
		EOF
	)
}

@test "properly fail if value contains hypthens" {
	declare -A args=()

	! (
		args.parse --port - <<-'EOF'
		@flag [port] - The port to open on
		EOF
	)
}

@test "properly fail if required flag not given" {
	declare -A args=()

	! (
		args.parse <<-'EOF'
		@flag <port> The port to open on
		EOF
	)
}
