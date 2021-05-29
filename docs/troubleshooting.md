# Troubleshooting

If you are receiving opaque errors, the following may help

## `bash: /usr/lib/jvm/default/bin: syntax error: operand expected (error token is "/usr/lib/jvm/default/bin")`

Ensure `args` exists as an associate array and NOT an index array. Create it _before_ calling out to `args.parse`


```sh
# Wrong
declare -a args

# Correct
declare -A args
```

## Not declaring variables

TODO: test this

If you wish to use a variable, please declare it before invoking `args.parse`. If your shell context has `set -u` enabled, you may have to declare it for variables that you do not use
