#!/usr/bin/env bash
eval "$GLUE_BOOTSTRAP"
bootstrap || exit

# makerepropkg *.zst
# repro -f *.zst

# pacman -Qlp ./*.zst

# toast --shell

main() {
	ensure.file glue.toml
	ensure.file glue-auto.toml

	toml.get_key project glue.toml
	local myProject="$REPLY"

	toml.get_key desc glue.toml
	local myDesc="$REPLY"

	toml.get_key name glue.toml
	local myName="$REPLY"

	toml.get_key email glue.toml
	local myEmail="$REPLY"

	toml.get_key version glue-auto.toml
	local myVer="$REPLY"; myVer="${myVer/-/_}"

	ensure.nonZero 'myProject' "$myProject"
	ensure.nonZero 'myDesc' "$myDesc"
	ensure.nonZero 'myName' "$myName"
	ensure.nonZero 'myEmail' "$myEmail"
	ensure.nonZero 'myVer' "$myVer"

	# glue useConfig(result-pacman-package)
	util.get_config "result-pacman-package/dev/PKGBUILD"
	pkgbuildFile="$REPLY"

	generated.in 'result-pacman-package'
	(
		cd "$GENERATED_DIR" || error.cd_failed
		mkdir dev
		cd dev || error.cd_failed

		tar --create --directory "$GLUE_WD" --file "$myProject-$myVer.tar.gz" --exclude './.git' \
				--exclude "$myProject-$myVer.tar.gz" --transform "s/^\./$myProject-$myVer/" ./

		cp "$pkgbuildFile" .
		sed -i -e "s/# Maintainer:.*/# Maintainer: $myName <$myEmail>/g" PKGBUILD
		sed -i -e "s/pkgname=.*\$/pkgname='$myProject'/g" PKGBUILD
		sed -i -e "s/pkgver=.*\$/pkgver='$myVer'/g" PKGBUILD
		sed -i -e "s/pkgdesc=.*\$/pkgdesc='$myDesc'/g" PKGBUILD
		sed -i -e "s/url=.*\$/url='https:\/\/github.com\/eankeen\/$myProject'/g" PKGBUILD
		sed -i -e "s/source=.*\$/source=\(\$pkgname-\$pkgver.tar.gz::\)/g" PKGBUILD
		local sum="$(sha256sum "$myProject-$myVer.tar.gz")"
		sum="${sum%% *}"
		sed -i -e "s/sha256sums=.*\$/sha256sums=\('$sum'\)/g" PKGBUILD

		namcap PKGBUILD
		makepkg -Cfsrc
		namcap ./*.zst
	) || exit
	generated.out
}

main "$@"

unbootstrap
