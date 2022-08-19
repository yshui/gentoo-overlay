# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{8..10} )
PYTHON_REQ_USE="sqlite"

inherit desktop optfeature python-single-r1 xdg bazel toolchain-funcs

DESCRIPTION="A spaced-repetition memory training program (flash cards)"
HOMEPAGE="https://apps.ankiweb.net"

LICENSE="AGPL-3+ BSD MIT GPL-3+ CC-BY-SA-3.0 Apache-2.0 CC-BY-2.5"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test record-sound playback latex"
RESTRICT="!test? ( test ) network-sandbox"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

bazel_external_uris="
	https://github.com/bazelbuild/rules_nodejs/releases/download/4.6.2/rules_nodejs-4.6.2.tar.gz
	https://github.com/bazelbuild/rules_python/archive/0.6.0.tar.gz -> rules_python-0.6.0.tar.gz
	https://github.com/bazelbuild/rules_rust/archive/adf2790f3ff063d909acd70aacdd2832756113a5.zip
	https://github.com/bazelbuild/rules_sass/archive/d0cda2205a6e9706ded30f7dd7d30c82b1301fbe.zip
	https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.0.2/bazel-skylib-1.0.2.tar.gz
	https://files.pythonhosted.org/packages/76/0a/b6c5f311e32aeb3b406e03c079ade51e905ea630fc19d1262a46249c1c86/click-8.0.1-py3-none-any.whl
	https://files.pythonhosted.org/packages/47/ca/f0d790b6e18b3a6f3bd5e80c2ee4edbb5807286c21cdd0862ca933f751dd/pip-21.1.3-py3-none-any.whl
	https://files.pythonhosted.org/packages/6d/16/75d65bdccd48bb59a08e2bf167b01d8532f65604270d0a292f0f16b7b022/pip_tools-5.5.0-py2.py3-none-any.whl
	https://files.pythonhosted.org/packages/77/83/1ef010f7c4563e218854809c0dff9548de65ebec930921dedf6ee5981f27/pkginfo-1.7.1-py2.py3-none-any.whl
	https://files.pythonhosted.org/packages/a2/e1/902fbc2f61ad6243cd3d57ffa195a9eb123021ec912ec5d811acf54a39f8/setuptools-57.1.0-py3-none-any.whl
	https://files.pythonhosted.org/packages/65/63/39d04c74222770ed1589c0eaba06c05891801219272420b40311cd60c880/wheel-0.36.2-py2.py3-none-any.whl
"
SRC_URI="https://github.com/ankitects/anki/archive/refs/tags/${PV}.tar.gz -> ${P}.tgz ${bazel_external_uris}"

RDEPEND="${PYTHON_DEPS}
	$(python_gen_cond_dep '
		dev-python/PyQt6[gui,svg,widgets,${PYTHON_USEDEP}]
		dev-python/PyQt6-WebEngine[${PYTHON_USEDEP}]
		dev-python/beautifulsoup4[${PYTHON_USEDEP}]
		dev-python/decorator[${PYTHON_USEDEP}]
		dev-python/jsonschema[${PYTHON_USEDEP}]
		dev-python/markdown[${PYTHON_USEDEP}]
		dev-python/requests[${PYTHON_USEDEP}]
		dev-python/send2trash[${PYTHON_USEDEP}]
		dev-python/PySocks[${PYTHON_USEDEP}]
		dev-python/protobuf-python[${PYTHON_USEDEP}]
		dev-python/orjson[${PYTHON_USEDEP}]
		dev-python/distro[${PYTHON_USEDEP}]
		dev-python/flask[${PYTHON_USEDEP}]
		dev-python/flask-cors[${PYTHON_USEDEP}]
		dev-python/waitress[${PYTHON_USEDEP}]
		record-sound? (
			dev-python/pyaudio[${PYTHON_USEDEP}]
			media-sound/lame
		)
		playback? (
			media-video/mpv
		)
		latex? (
			app-text/texlive
			app-text/dvipng
		)
	')
"
BDEPEND="test? (
	${RDEPEND}
	$(python_gen_cond_dep '
		dev-python/nose[${PYTHON_USEDEP}]
		dev-python/mock[${PYTHON_USEDEP}]
		')
	)
	net-misc/rsync
"

PATCHES=(
	"${FILESDIR}"/inc_qt_timeout.patch
	"${FILESDIR}"/update.patch
)

src_unpack() {
	unpack ${P}.tgz
	bazel_load_distfiles ${bazel_external_uris}
}

src_prepare() {
	default
	sed -i -e "s/updates=True/updates=False/" \
		qt/aqt/profiles.py || die
}

src_compile() {
	if tc-is-clang ; then
		export LDSHARED="/usr/bin/clang -shared"
	fi
	export JAVA_HOME=/usr/lib/jvm/openjdk-bin-11
	gcc --version
	ebazel build --action_env="PYO3_PYTHON=${PYTHON}" -c opt wheels
	ebazel shutdown
}

src_install() {
	doicon qt/bundle/lin/${PN}.png
	domenu qt/bundle/lin/${PN}.desktop

	PIP_CONFIG_FILE=/dev/null ${PYTHON} -m pip install --isolated --root="${D}" --ignore-installed --no-deps .bazel/out/k8-opt/bin/qt/aqt/aqt-*.whl .bazel/out/k8-opt/bin/pylib/anki/anki-*.whl

	python_newscript qt/runanki.py anki
	python_optimize ${ED}
}

pkg_postinst() {
	xdg_pkg_postinst
}
