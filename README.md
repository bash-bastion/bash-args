# bash-arg

A cute little Bash library for easy argument parsing in your applications

## Benefits

- Fast (no subshells, all builtins)
- Easy API

## Installation

```sh
# With Basher
basher install eankeen/bash-arg

# or cURL
curl -O "https://raw.githubusercontent.com/eankeen/bash-arg/main/bash-arg.sh"
```

## Usage

### Simple

```bash
# Source basher...

# If basher
source "$(basher package-path eankeen/bash-arg)/bash-arg.sh"

# If cURL
source "./bash-arg.sh"


# bash-arg stores all its results in the
# 'args' associative array
declare -A args=()

# Call 'arguments', passinng in the current options.
# Usually, you would replace '--port 3000' with "$@",
# in a script, but since we're in an interactive shell
# session, just specify the arguments manually
arguments --port 3000 <<-'EOF'
@flag [port.p] {3000} - The port to open on
EOF

# The above says parse a 'flag' with an *optional* long option of '--port' and a short
# option of '-p', with a default value of '3000', with the given description.
# The format is space sensitive and must be on one line.

# You can do `<port.p>` to make the option / flag required

# Then, use the argument
https
```

### More examples

```bash
source bash-arg.sh
declare -A args=()

arguments --port 3005 <<-'EOF'
@flag [port.p] {3000} - The port to open on
EOF

echo "${args[port]}" # 3005

arguments --port <<-'EOF'
@flag [port.p] {3000} - The port to open on
EOF

# `exit 1` because a supplied flag with a value must have a value

arguments <<-'EOF'
@flag [port.p] {3000} - The port to open on
EOF
echo "${args[port]}" # 3000
```

### Details

CURRENT STATUS: ALPHA

- pragma: required
- argName: required
- defaultValue: optional
- description: optional

TODO

- arg for double hypthen
- help menu command
