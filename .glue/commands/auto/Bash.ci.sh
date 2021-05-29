#!/usr/bin/env bash
eval "$GLUE_BOOTSTRAP"
bootstrap || exit

unbootstrap
