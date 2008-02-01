# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-wireless/ipw2200-firmware/ipw2200-firmware-3.0.ebuild,v 1.4 2007/05/24 09:05:31 uberlord Exp $

MY_P="RT61_Firmware_V${PV}"
S=${WORKDIR}/${MY_P}

DESCRIPTION="Firmware for the Ralink RT61 wireless PCI adapters"

HOMEPAGE="http://www.ralinktech.com/"
SRC_URI="http://www.ralinktech.com.tw/data/${MY_P}.zip"

LICENSE="ralink"
SLOT="0"
KEYWORDS="~amd64 x86"

IUSE=""
DEPEND=""
RDEPEND="|| ( >=sys-fs/udev-096 >=sys-apps/hotplug-20040923 )"

src_install() {
	insinto /lib/firmware
	doins *.bin

	doins LICENSE.ralink-firmware.txt
}
