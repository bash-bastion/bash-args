#!/usr/bin/env sh
set -ex

# wget https://github.com/eankeen/bash-args/archive/refs/tags/v0.5.0.tar.gz
# mv v0.5.0.tar.gz bash-args_0.5.0.orig.tar.gz
# tar xf bash-args_0.5.0.orig.tar.gz
cd 'bash-args-0.5.0'
rm -rf debian
mkdir -p debian

# cme

# dch --create -v 0.5.0-1 --package bash-args || :
dch --create --distribution unstable --package "bash-args" --newversion 0.5.0-1.test "some nice message" || :

# compat for debhelper tool
cat >| debian/compat  <<"EOF"
10
EOF

# binary packages (second section) can have multiple
cat >| debian/control <<"EOF"
Source: bash-args
Maintainer: Edwin Kofler <edwin@kofler.dev>
Section: misc
Priority: optional
Standards-Version: 3.9.2
Build-Depends: debhelper (>= 9)

Package: args.parse
Architecture: all
Depends: ${shlibs:Depends}, ${misc:Depends}
Description: A cute little Bash library for blazing fast argument parsing
EOF

touch debian/copyright

cat >| debian/rules <<"EOF"
#!/usr/bin/make -f
%:
	dh $@
EOF

mkdir -p debian/source
cat >| debian/source/format <<"EOF"
3.0 (quilt)
EOF

cat >| debian/args.parse.dirs <<"EOF"
usr/bin
EOF

cd debian

debuild -us -uc
