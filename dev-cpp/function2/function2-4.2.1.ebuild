EAPI=7

inherit cmake

DESCRIPTION="An improved drop-in replacement to std::function"
HOMEPAGE="https://naios.github.io/function2/"

KEYWORDS="~amd64 ~x86"

SRC_URI=("https://github.com/Naios/${PN}/archive/refs/tags/${PV}.tar.gz")

LICENSE="Boost-1.0"
SLOT="0"

IUSE="test"

PATCHES=("${FILESDIR}/function2-4.2.0-skip_docs.patch")

src_configure() {
    local mycmakeargs=(
        -DBUILD_TESTING=$(usex test)
    )
	cmake_src_configure
}
