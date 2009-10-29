# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/mt-daapd/mt-daapd-0.2.4.2.ebuild,v 1.7 2009/05/11 20:38:06 ssuominen Exp $

EAPI=2
WANT_AUTOMAKE="1.9"
inherit autotools eutils subversion

DESCRIPTION="A multi-threaded implementation of Apple's DAAP server"
HOMEPAGE="http://www.mt-daapd.org"
#SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"
SRC_URI=""
ESVN_REPO_URI="https://mt-daapd.svn.sourceforge.net/svnroot/mt-daapd/trunk"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm ~mips ppc sh sparc x86"
IUSE="+avahi encode flac vorbis"

RDEPEND="media-libs/libid3tag
	sys-libs/gdbm
	dev-db/sqlite
	avahi? ( net-dns/avahi[dbus] )
	!avahi? ( net-misc/mDNSResponder )
	vorbis? ( media-libs/libvorbis )
	flac? ( media-libs/flac )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

src_prepare() {
	cp "${FILESDIR}"/${PN}.init.2 initd

	epatch "$FILESDIR/hack.patch"

	if use avahi; then
		sed -i -e 's:#USEHOWL need mDNSResponderPosix:need avahi-daemon:' initd
	else
		sed -i -e 's:#USEHOWL ::' initd
	fi

	eautoreconf
}

src_configure() {
	local myconf

	if use avahi; then
		myconf="--enable-avahi --enable-mdns"
	else
		myconf="--disable-avahi --enable-mdns"
	fi

	if use encode; then
		myconf="${myconf} --enable-ffmpeg"
	fi

	econf $(use_enable vorbis oggvorbis) $(use_enable flac) \
		--disable-maintainer-mode \
		--enable-sqlite3 \
		${myconf}
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."

	insinto /etc
	newins contrib/mt-daapd.conf mt-daapd.conf.example
	doins contrib/mt-daapd.playlist

	newinitd initd ${PN}

	keepdir /var/cache/mt-daapd /etc/mt-daapd.d
	dodoc AUTHORS ChangeLog CREDITS NEWS README TODO
}

pkg_postinst() {
	einfo
	elog "You have to configure your mt-daapd.conf following"
	elog "/etc/mt-daapd.conf.example file."
	einfo

	if use vorbis; then
		einfo
		elog "You need to edit you extensions list in /etc/mt-daapd.conf"
		elog "if you want your mt-daapd to serve ogg files."
		einfo
	fi

	einfo
	elog "If you want to start more than one ${PN} service, symlink"
	elog "/etc/init.d/${PN} to /etc/init.d/${PN}.<name>, and it will"
	elog "load the data from /etc/${PN}.d/<name>.conf."
	elog "Make sure that you have different cache directories for them."
	einfo
}
