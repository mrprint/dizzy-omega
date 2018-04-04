# Maintainer: Nikolay (unDEFER) Krivchenkov <undefer@gmail.com>
pkgname=dizzy_omega
pkgver=0.17
pkgrel=1
epoch=
pkgdesc="the sequel of the game Dizzy Y"
arch=(x86_64)
url="https://dizzy-omega.sourceforge.io"
license=('GPL3')
groups=()
depends=('sdl2' 'sdl2_image')
makedepends=('dmd' 'dub')
checkdepends=()
optdepends=()
provides=()
conflicts=()
replaces=()
backup=()
options=()
install=
changelog=
source=("$pkgname-$pkgver.tar.xz")
noextract=()
md5sums=("INSERT-REAL-MD5SUM-HERE")
validpgpkeys=()

prepare() {
	cd "$pkgname-$pkgver"
}

build() {
	cd "$pkgname-$pkgver"
	dub build -c Manjaro
}

check() {
	cd "$pkgname-$pkgver"
}

package() {
	cd "$pkgname-$pkgver"
	make DESTDIR="$pkgdir/" install
}
