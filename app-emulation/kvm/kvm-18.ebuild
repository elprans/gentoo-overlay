# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit linux-mod multilib

DESCRIPTION="KVM Virtualization package"
HOMEPAGE="http://kvm.qumranet.com/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="inkernel"

RDEPEND="media-libs/libsdl
	!app-emulation/qemu"
DEPEND="${RDEPEND}"

pkg_setup() {
	MODULE_NAMES="kvm(drivers/kvm:${S}/kernel) \
				kvm-intel(drivers/kvm:${S}/kernel) \
				kvm-amd(drivers/kvm:${S}/kernel)"
	BUILD_TARGETS="clean all"
	linux-mod_pkg_setup
}

src_compile() {
	MYCONF="--prefix=/usr --disable-gcc-check --qemu-cc=gcc"
	if use inkernel; then
		# Stupid configure script can't take --without-patched-kernel
		MYCONF="${MYCONF} --with-patched-kernel"
	fi
	./configure ${MYCONF} || die "configure failed"

	if ! use inkernel; then
		linux-mod_src_compile
		#cd kernel
		#ARCH="$(tc-arch-kernel)" emake || die "making kernel module failed"
		#cd ..
	fi
	emake -C user || die "making user failed"
	emake -C qemu || die "making qemu failed"
}

src_install() {
#	if ! use inkernel; then
#		addpredict /$(get_libdir)/modules/${KV_FULL}
#	fi
	linux-mod_src_install
	emake -C user DESTDIR=${D} install || die "installing user failed"
	emake -C qemu DESTDIR=${D} install || die "installing qemu failed"
	#emake install || die "install failed"
}
