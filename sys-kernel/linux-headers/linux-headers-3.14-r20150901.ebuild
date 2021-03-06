# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# gentoo-x86: sys-kernel/linux-headers-3.14
# riscv-linux: 0f987a9b0723cd6f9215891dd8b2c314ca6132a5

EAPI="4"

ETYPE="headers"
H_SUPPORTEDARCH="alpha amd64 arc arm arm64 avr32 bfin cris frv hexagon hppa ia64 m32r m68k metag microblaze mips mn10300 openrisc ppc ppc64 riscv s390 score sh sparc tile x86 xtensa"
inherit kernel-2
detect_version

PATCH_VER="1"
SRC_URI="mirror://gentoo/gentoo-headers-base-${PV}.tar.xz
	${PATCH_VER:+mirror://gentoo/gentoo-headers-${PV}-${PATCH_VER}.tar.xz}"

KEYWORDS="riscv"

DEPEND="app-arch/xz-utils
	dev-lang/perl"
RDEPEND="!!media-sound/alsa-headers"

S=${WORKDIR}/gentoo-headers-base-${PV}

src_unpack() {
	unpack ${A}
}

src_prepare() {
        patch -p1 < "${FILESDIR}/${P}-riscv-${PR}.patch" || die "RISC-V"
        patch -p1 < "${FILESDIR}/${P}-config_64bit.patch" || die "RISC-V"
	[[ -n ${PATCH_VER} ]] && EPATCH_SUFFIX="patch" epatch "${WORKDIR}"/${PV}
}

src_install() {
	kernel-2_src_install
	cd "${ED}"
	egrep -r \
		-e '(^|[[:space:](])(asm|volatile|inline)[[:space:](]' \
		-e '\<([us](8|16|32|64))\>' \
		.

	egrep -l -r -e '__[us](8|16|32|64)' "${ED}" | xargs grep -L linux/types.h

	# hrm, build system sucks
	find "${ED}" '(' -name '.install' -o -name '*.cmd' ')' -delete
	find "${ED}" -depth -type d -delete 2>/dev/null

	# provided by libdrm (for now?)
	rm -rf "${ED}"/$(kernel_header_destdir)/drm
}

src_test() {
	emake ARCH=$(tc-arch-kernel) headers_check || die
}
