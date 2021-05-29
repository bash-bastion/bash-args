#!/usr/bin/env sh
set -ex

# makerepropkg *.zst
# repro -f *.zst

makepkg -Cfsrc
# makepkg -Cfsrc

namcap PKGBUILD
namcap ./*.zst

pacman -Qlp ./*.zst

toast --shell
