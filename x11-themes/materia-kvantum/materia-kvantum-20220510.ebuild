# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="GTK port of Materia Theme for Plasma 5 desktop."
HOMEPAGE="https://github.com/PapirusDevelopmentTeam/materia-kde"

if [[ ${PV} == 99999999 ]]; then
	inherit git-r3
	KEYWORDS=""
	EGIT_REPO_URI="${HOMEPAGE}"
else
	SRC_URI="${HOMEPAGE}/archive/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="GPL-3"
SLOT="0"
IUSE="+ico"

DEPEND="
	ico? ( x11-themes/papirus-icon-theme )
	x11-themes/kvantum
"
RDEPEND="${DEPEND}"
S="${WORKDIR}/materia-kde-${PV}"

src_install() {
	THEMES="Kvantum"
	THEMES="${THEMES}" default
}
