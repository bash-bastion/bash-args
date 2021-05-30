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

	# TODO: use function
	mkdir -p .glue/generated/tool-makepkg

	# TODO: get these values somewhere else
	toml.get_key name glue.toml
	local myPkg="$REPLY"
	local myName="Edwin Kofler"
	local myEmail="edwin@kofler.dev"
	toml.get_key desc glue.toml
	local myDesc="$REPLY"

	toml.get_key version glue-auto.toml
	local myVer="$REPLY"
	myVer="${myVer/-/_}"

	ensure.nonZero 'myVer' "$myVer"
	# glue useConfig(tool-makepkg)
	util.get_config "tool-makepkg/dev/PKGBUILD"
	pkgbuildFile="$REPLY"

	generated.in 'result-pacman-package'
	(
		mkdir -p .glue/generated/tool-makepkg/dev
		cd .glue/generated/tool-makepkg/dev || error.cd_failed

		cp "$pkgbuildFile" .

		# TODO: bash templating
		sed -i -e "s/# Maintainer:.*/# Maintainer: $myName <$myEmail>/g" PKGBUILD
		sed -i -e "s/pkgname=.*\$/pkgname='$myPkg'/g" PKGBUILD
		sed -i -e "s/pkgver=.*\$/pkgver='$myVer'/g" PKGBUILD
		sed -i -e "s/pkgdesc=.*\$/pkgdesc='$myDesc'/g" PKGBUILD
		sed -i -e "s/url=.*\$/url='https:\/\/github.com\/eankeen\/$myPkg'/g" PKGBUILD
		sed -i -e "s/source=.*\$/source=\(\$pkgname-\$pkgver.tar.gz::http:\/\/localhost:9334\/v\$pkgver.tar.gz\)/g" PKGBUILD

		# TODO: assumption on working directory
		tar --create --directory "$GLUE_WD" --file "$myPkg-$myVer.tar.gz" ../"$myPkg"
		rm -rf "$myPkg-$myVer"
		# tar xf "$myPkg-$myVer.tar.gz"
		# mv "$myPkg" "$myPkg-$myVer"
		# rm -rf "$myPkg-$myVer/.git"

		local sum="$(sha256sum "$myPkg-$myVer.tar.gz")"
		sum="${sum%% *}"
		sed -i -e "s/sha256sums=.*\$/sha256sums=\('$sum'\)/g" PKGBUILD

		makepkg -Cfsrc
	) || exit
	generated.out

	# TODO: think about more fine grained linting control in the whole SDLC
	# namcap PKGBUILD
	# namcap ./*.zst

}

main "$@"

unbootstrap
