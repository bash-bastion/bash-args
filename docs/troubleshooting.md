# Troubleshooting

If you are receiving opaque errors, the following may help

## `bash: /usr/lib/jvm/default/bin: syntax error: operand expected (error token is "/usr/lib/jvm/default/bin")`

Ensure `args` exists as an associate array and NOT an index array. Create it _before_ calling out to `bash-args`


```sh
# Wrong
declare -a args

# Correct
declare -A args
```

## Not sourcing `bash-args`

If you do not source `bash-args` the variables that it sets will not be available to your current shell execution context

```sh
# Wrong
bash-args parse "$@" <<-"EOF"
@flag [port.p] {3000} - The port to open on
EOF

# Correct
source bash-args parse parse "$@" <<-"EOF"
@flag [port.p] {3000} - The port to open on
EOF
```

## Not declaring variables

TODO: test this

If you wish to use a variable, please declare it before invoking `bash-args`. If your shell context has `set -u` enabled, you may have to declare it for variables that you do not use
