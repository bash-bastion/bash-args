#!/usr/bin/env sh
set -ex

# makerepropkg *.zst
# repro -f *.zst

# makepkg -Cfsr
makepkg -Cfsrc

namcap PKGBUILD
namcap ./*.zst

pacman -Qlp ./*.zst
