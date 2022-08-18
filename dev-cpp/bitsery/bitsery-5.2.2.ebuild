EAPI=7

inherit cmake git-r3

DESCRIPTION="Header only C++ binary serialization library"
HOMEPAGE="https://github.com/fraillt/bitsery"

KEYWORDS="~amd64 ~x86"

EGIT_REPO_URI="${HOMEPAGE}"
EGIT_COMMIT="c0fc083c9de805e5825d7553507569febf6a6f93"

LICENSE="MIT"
SLOT="0"

IUSE="test"

src_configure() {
	local mycmakeargs=(
		-DCMAKE_INSTALL_LIBDIR="${EPREFIX}/usr/$(get_libdir)"
		-DCMAKE_INSTALL_SYSCONFDIR="${EPREFIX}/etc"
		-DBITSERY_BUILD_TESTS=$(usex test)
	)
	cmake_src_configure
}
