# args

A cute little Bash library for blazing fast argument parsing

## Summary

- Uses only builtins
- Uses no subshells
- Simple API

## Installation

```sh
# With Basher
basher install eankeen/args

# With Git
git clone "https://github.com/eankeen/args" ~/.args
```

## Usage

### Init

Before executing the `args` function, you need to init it first

```sh
# With Basher
source "$(basher package-path eankeen/args)/bin/args-init"

# With Git
source ~/.args/bin/args-init
```

### Using

```bash
# Pass through your command line arguments to 'args'
# Pass your argument specification through stdin (see more examples below)
args "$@" <<-'EOF'
@flag [port.p] {3000} - The port to open on
EOF

# Use the long flags (or short, if you only used short) flags to access the flag value
echo "Will use port ${args[port]}"

# 'postArgs' array contains everything after the first '--'
echo "Args: ${postArgs[*]}"

# Is a string of the initial stdin to 'args'
echo "$argsSpec"
```

### More examples

The following are all valid lines to specify the shape of the CLI. Of course,
please don't specify the same flag multiple times

```bash
args --port 3005 <<-'EOF'
@flag [port] {3000} - The port to open on (with a default value of 3000)
@flag [port.p] {3000} - The port to open on (with a default value of 3000)
@flag [.p] - The port to open on (with no default value)
@flag <port> - The port to open on (a required option, will exit failure if this isn't passed)
EOF
```

### Details

CURRENT STATUS: BETA with missing features

- TODO: support arguments
- TODO: die with line, but only show line with debug mode
- environment variables?
- ensure it works with set -e and set -u
