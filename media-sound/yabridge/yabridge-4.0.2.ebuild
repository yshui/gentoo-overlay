EAPI=8

CRATES="
anyhow-1.0.57
atty-0.2.14
autocfg-1.1.0
bitflags-1.3.2
cc-1.0.73
cfg-if-1.0.0
clap-3.1.18
clap_lex-0.2.0
clipboard-win-4.4.1
colored-2.0.0
crossbeam-channel-0.5.4
crossbeam-deque-0.8.1
crossbeam-epoch-0.9.8
crossbeam-utils-0.8.8
dirs-4.0.0
dirs-next-2.0.0
dirs-sys-0.3.7
dirs-sys-next-0.1.2
either-1.6.1
endian-type-0.1.2
errno-0.2.8
errno-dragonfly-0.1.2
error-code-2.3.1
fd-lock-3.0.5
getrandom-0.2.6
goblin-0.5.2
hashbrown-0.11.2
hermit-abi-0.1.19
indexmap-1.8.2
io-lifetimes-0.6.1
is_executable-1.0.1
itoa-0.4.8
lazy_static-1.4.0
libc-0.2.126
linux-raw-sys-0.0.46
log-0.4.17
memchr-2.5.0
memoffset-0.6.5
nibble_vec-0.1.0
nix-0.23.1
num_cpus-1.13.1
os_str_bytes-6.1.0
plain-0.2.3
proc-macro2-1.0.39
promptly-0.3.1
quote-1.0.18
radix_trie-0.2.1
rayon-1.5.3
rayon-core-1.9.3
redox_syscall-0.2.13
redox_users-0.4.3
reflink-0.1.3
rustix-0.34.8
rustyline-9.1.2
ryu-0.2.8
same-file-1.0.6
scopeguard-1.1.0
scroll-0.11.0
scroll_derive-0.11.0
serde-1.0.137
serde_derive-1.0.137
serde_jsonrc-0.1.0
smallvec-1.8.0
str-buf-1.0.6
strsim-0.10.0
syn-1.0.96
term_size-0.3.2
termcolor-1.1.3
terminal_size-0.1.17
textwrap-0.11.0
textwrap-0.15.0
thiserror-1.0.31
thiserror-impl-1.0.31
toml-0.5.9
unicode-ident-1.0.0
unicode-segmentation-1.9.0
unicode-width-0.1.9
utf8parse-0.2.0
walkdir-2.3.2
wasi-0.10.2+wasi-snapshot-preview1
which-4.2.5
winapi-0.3.9
winapi-util-0.1.5
winapi-i686-pc-windows-gnu-0.4.0
winapi-x86_64-pc-windows-gnu-0.4.0
windows-sys-0.30.0
windows_aarch64_msvc-0.30.0
windows_i686_gnu-0.30.0
windows_i686_msvc-0.30.0
windows_x86_64_gnu-0.30.0
windows_x86_64_msvc-0.30.0
xdg-2.4.1"

inherit meson cargo git-r3

DESCRIPTION="A modern and transparent way to use Windows VST2 and VST3 plugins on Linux"
HOMEPAGE="https://github.com/robbert-vdh/yabridge"

SRC_URI="https://github.com/robbert-vdh/${PN}/archive/refs/tags/${PV}.tar.gz
 $(cargo_crate_uris)"
EGIT_REPO_URI="https://github.com/robbert-vdh/vst3sdk"
EGIT_COMMIT="v3.7.5_build_44-patched"
EGIT_CHECKOUT_DIR="${WORKDIR}/vst3sdk"

KEYWORDS="~amd64"

LICENSE="GPL-3"
SLOT="0"


DEPEND="
	dev-cpp/asio
	dev-cpp/bitsery
	dev-cpp/gulrak-filesystem
	dev-cpp/tomlplusplus
	dev-cpp/function2
	x11-libs/libxcb[abi_x86_32]
	virtual/wine[abi_x86_32]
"

PATCHES="
  ${FILESDIR}/xcb-32bit.patch
  ${FILESDIR}/reflink.patch
"

src_unpack() {
	unpack ${PV}.tar.gz
	git-r3_src_unpack
	cargo_src_unpack
}

src_prepare() {
	rm -v subprojects/vst3.wrap
	ln -s ${WORKDIR}/vst3sdk subprojects/vst3
	default
}

src_configure() {
	local emesonargs=(
		--cross-file=${S}/cross-wine.conf
		-Dbitbridge=true
		-Dsystem-asio=true
		-Db_lto=false
		-Db_pie=false
		-Dbuild.cpp_link_args="$LDFLAGS"
		-Dcpp_link_args="$LDFLAGS -mwindows"
	)
	meson_src_configure

	cd tools/yabridgectl
	cargo_src_configure
}

src_compile() {
	meson_src_compile

	cd tools/yabridgectl
	cargo_src_compile
}

src_install() {
	dobin ${WORKDIR}/${P}-build/${PN}-host{,-32}.exe{,.so}
	dolib.so ${WORKDIR}/${P}-build/lib${PN}-{,chainloader-}{vst2,vst3}.so

	cd tools/yabridgectl
	cargo_src_install
}
