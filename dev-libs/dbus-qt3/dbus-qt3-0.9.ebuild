# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/dbus-qt3-old/dbus-qt3-old-0.70.ebuild,v 1.15 2008/08/18 18:50:28 rbu Exp $

inherit qt3

MY_PN="dbus-1-qt3"

DESCRIPTION="D-BUS Qt3 bindings compatible with old application API and new dbus"
HOMEPAGE="http://freedesktop.org/wiki/Software/dbus"
SRC_URI="http://people.freedesktop.org/~krake/dbus-1-qt3/${MY_PN}-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
IUSE="debug"

RDEPEND=">=sys-apps/dbus-0.91"
DEPEND="${RDEPEND}
	=x11-libs/qt-3*"

S=${WORKDIR}/${MY_PN}-${PV}

src_compile() {
	econf --enable-qt3 --with-qt3-moc=${QTDIR}/bin/moc \
		  $(use_enable debug qt-debug) \
		|| die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
}
