# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/kde-misc/knetworkmanager/knetworkmanager-0.2.2_p20080528.ebuild,v 1.1 2008/06/24 17:55:41 rbu Exp $

inherit kde eutils subversion cmake-utils

MY_PV="${PV}"
MY_P=${PN}-${MY_PV}


DESCRIPTION="A KDE frontend for NetworkManager"
HOMEPAGE="http://en.opensuse.org/Projects/KNetworkManager"
LICENSE="GPL-2"
#SRC_URI="ftp://ftp.kde.org/pub/kde/stable/apps/KDE3.x/network/${P}.tar.bz2"
#SRC_URI="mirror://gentoo/${MY_P}.tar.bz2"
ESVN_REPO_URI="svn://anonsvn.kde.org/home/kde/branches/work/knetworkmanager/"
KEYWORDS="~amd64 ~ppc ~x86"

IUSE="cisco openvpn pptp dialup"

DEPEND="=net-misc/networkmanager-0.7*
	=kde-base/kdelibs-3.5*
	>=dev-libs/dbus-qt3-0.8.1
	sys-apps/hal
	net-wireless/wireless-tools
	>=dev-libs/libnl-1.1
	cisco?   ( <net-misc/networkmanager-vpnc-0.7.0 )
	openvpn? ( <net-misc/networkmanager-openvpn-0.3.3 )
	pptp?    ( <net-misc/networkmanager-pptp-0.7.0 )
	dialup? ( || ( =kde-base/kppp-3.5* =kde-base/kdenetwork-3.5* ) )"

RDEPEND="${DEPEND}"
DEPEND="${DEPEND}
	>=sys-kernel/linux-headers-2.6.19"

S="${WORKDIR}/${MY_P}"

pkg_setup() {
	kde_pkg_setup

	if has_version "<sys-apps/dbus-0.9" && ! built_with_use sys-apps/dbus qt3 ; then
		echo
		eerror "You must rebuild sys-apps/dbus with USE=\"qt3\" or use a newer version of dbus"
		die "sys-apps/dbus not built with qt3 bindings"
	fi
}

src_unpack() {
	#kde_src_unpack
	
	#OLD_S="${S}"
	# Set the original uri to a temp var
	#ESVN_REPO_URI1=${ESVN_REPO_URI}
	#ESVN_OPTIONS1="${ESVN_OPTIONS}"

	# Checkout kdereview
	#ESVN_REPO_URI="svn://anonsvn.kde.org/home/kde/branches/extragear/kde3/network"
	#ESVN_OPTIONS="-N"
	#subversion_src_unpack

	# Checkout admin
	#ESVN_REPO_URI="svn://anonsvn.kde.org/home/kde/branches/KDE/3.5/kde-common/admin"
	#ESVN_OPTIONS=""
	#S="${S}/admin"
	#subversion_src_unpack

	# Checkout knetworkmanager
	#ESVN_REPO_URI=${ESVN_REPO_URI1}
	#ESVN_OPTIONS="${ESVN_OPTIONS1}"
	#S="${S}/../${PN}"
	subversion_src_unpack

	#S="${OLD_S}"

	cd "${S}"

	#epatch "${FILESDIR}/${PN}-0.2-pam_console-fix.patch"
	#epatch "${FILESDIR}/${PN}-0.2.1-fixbuild_u64-hschaa-01.patch"
}

src_compile() {
	set-kdedir
	export PREFIX="${KDEDIR}"
	local myconf="$(use_with cisco vpnc) \
		$(use_with openvpn) \
		$(use_with pptp) \
		$(use_with dialup) \
		--with-distro=gentoo --disable-rpath"
	kde_src_compile
}

src_install() {
	kde_src_install

	# kde.eclass sets sysconfdir too weird for us, delete conf from there and reinstall to /etc
	set-kdedir
	rm -rf "${D}/${KDEDIR}/etc"
	insinto /etc/dbus-1/system.d/
	doins knetworkmanager-0.7/knetworkmanager.conf
}
