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
# Declaring `args` may be required
declare -a args

# Pass through your command line arguments to 'args'
# Pass your argument specification through stdin (see more examples below)
args.parse "$@" <<-"EOF"
@flag [port.p] {3000} - The port to open on
EOF

# Use either the long or short flags to get value
echo "Using port '${args[port]}'"

# 'argsCommands' contains all commands (arguments that are not
# either flags or values for flags)
echo "argsCommands: ${argsCommands[*]}"

# 'argsPostHyphen' contains everything after the first '--'
echo "argsPostHyphen: ${argsPostHyphen[*]}"

# Use argsSpec to print an automated help menu
➤ args.do print-help <<< "$argsSpec"
Usage:
    stdin [flags] [<requiredFlags>] <arguments>

Flags:
    [--number] (default: 3000) - The port to open on
```

### Argument Specification

The following are valid lines and their explanations to pass as stdin to `args.parse`

- `@flag [verbose] - Enable verbose logging`

`verbose` is a boolean flag. Any argument succeeding it will not be interpreted as a value to the flag

- `@flag [port] {} - Port to open on`

`port` is _not_ a boolean flag. You must specify a value if you decide to pass it to the command line. By default, it will be empty

- `@flag [port] {3000} - Port to open on`

Same as previous, but the default value is `3000`

- `@flag [port.p] {3000} - Port to open on`

Same as previous, but you can also specify the value with `-p`. Note that the `port` _and_ `p` properties will be properly populated in the `args` associate array

- `@flag [.p] {3000} - Port to open on`

Same as previous before previous, but only specify the short argument

- `@flag <port.p> - Port to open on`

Specify a non-boolean flag, `port`, and require that it's value _must_ be specified with either `-p` or `--port`. This makes the `{3000}` redundant and unecessary. Of course, you can use the sideways carrots with other variants

### Common Issues

Not setting `args` with `set -u`

### Details

CURRENT STATUS: BETA

- fix help menu
- die if unknown flag passed
- TODO: make help menu prettier
