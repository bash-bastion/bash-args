# Troubleshooting

If you are receiving opaque errors, the following may help

## Not declaring variables

If you wish to use a variable, please declare it before invoking `args.parse`. If your shell context has `set -u` enabled, you may have to declare it for variables that you do not use
