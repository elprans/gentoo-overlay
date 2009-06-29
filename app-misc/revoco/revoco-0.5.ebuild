# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit toolchain-funcs linux-info

DESCRIPTION="Tool for controlling Logitech MX Revolution mouses"
HOMEPAGE="http://goron.de/~froese/"
SRC_URI="http://goron.de/~froese/revoco/${P}.tar.gz"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~x86 ~amd64"

IUSE=""

RDEPEND=">=sys-fs/udev-104"

CONFIG_CHECK="USB_HIDDEV"
ERROR_USB_HIDDEN="You need to the CONFIG_USB_HIDDEV option turned on."

src_compile() {
	emake || die "make failed"
}

src_install() {
	insinto "/etc/udev/rules.d"
	doins "${FILESDIR}/90-mxrevolution.rules"
	dobin ${PN} || die
}

pkg_postinst() {
	elog "Your user needs to be in the usb group to use revoco."
}
