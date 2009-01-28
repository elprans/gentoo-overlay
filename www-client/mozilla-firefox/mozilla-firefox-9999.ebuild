# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-client/mozilla-firefox/mozilla-firefox-3.0.1.ebuild,v 1.5 2008/07/30 17:58:51 armin76 Exp $
EAPI="1"
WANT_AUTOCONF="2.1"

inherit flag-o-matic toolchain-funcs eutils mozconfig-3 makeedit mercurial multilib fdo-mime autotools mozextension

LANGS="af ar be ca cs da de el en-GB en-US es-AR es-ES eu fi fr fy-NL ga-IE gu-IN he hu id it ja ka ko ku lt mk mn nb-NO nl nn-NO pa-IN pl pt-BR pt-PT ro ru si sk sl sq sr sv-SE tr uk zh-CN zh-TW"
NOSHORTLANGS="en-GB es-AR pt-BR zh-CN"

MY_PV=${PV/3/}

DESCRIPTION="Firefox Web Browser"
HOMEPAGE="http://www.mozilla.com/firefox"

KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86"
SLOT="scm"
LICENSE="|| ( MPL-1.1 GPL-2 LGPL-2.1 )"
IUSE="java mozdevelop bindist restrict-javascript iceweasel +xulrunner qt4"

SRC_URI=""

RDEPEND="java? ( virtual/jre )
	>=sys-devel/binutils-2.16.1
	>=dev-libs/nss-3.12
	>=dev-libs/nspr-4.7.1
	>=media-libs/lcms-1.17
	>=app-text/hunspell-1.1.9
	>=net-libs/xulrunner-${PV}"

DEPEND="${RDEPEND}
	dev-util/pkgconfig
	java? ( >=dev-java/java-config-0.2.0 )"

PDEPEND="restrict-javascript? ( x11-plugins/noscript )"

S=${WORKDIR}/mozilla-central

# Needed by src_compile() and src_install().
# Would do in pkg_setup but that loses the export attribute, they
# become pure shell variables.
export MOZ_CO_PROJECT=browser
export BUILD_OFFICIAL=1
export MOZILLA_OFFICIAL=1

sedpatch_one() {
	local targetdir="${T}/sedpatches"
	local patchfile="${1}"
	local targetpatch="${targetdir}/$(basename ${patchfile})"

	mkdir -p "${targetdir}"

	awk "BEGIN {f=\"${targetpatch}\"++d} f{print > f} /^#--8</{f=\"${targetpatch}\"++d}" "${patchfile}"

	for f in ${targetpatch}?*; do
		targetfile=$(sed -n -e "s/#@@\\(.*\\)/\\1/ p" "${f}")
		sed -i -e "s/@@@@@SLOT@@@@@/${SLOT}/g" "${f}"
		sed -i -f "${f}" "${S}/${targetfile}"
	done
}

esedpatch() {
	local srcdir="${1}"

	for p in ${srcdir}/*.sedpatch; do
		einfo "Applying $(basename ${p})"
		sedpatch_one "${p}"
	done
}

pkg_setup(){
	if ! built_with_use x11-libs/cairo X; then
		eerror "Cairo is not built with X useflag."
		eerror "Please add 'X' to your USE flags, and re-emerge cairo."
		die "Cairo needs X"
	fi

	if ! built_with_use --missing true x11-libs/pango X; then
		eerror "Pango is not built with X useflag."
		eerror "Please add 'X' to your USE flags, and re-emerge pango."
		die "Pango needs X"
	fi

	if ! use bindist && ! use iceweasel; then
		elog "You are enabling official branding. You may not redistribute this build"
		elog "to any users on your network or the internet. Doing so puts yourself into"
		elog "a legal problem with Mozilla Foundation"
		elog "You can disable it by emerging ${PN} _with_ the bindist USE-flag"

	fi
}

src_unpack() {

	EHG_REPO_URI="http://hg.mozilla.org/mozilla-central/"
	EHG_PROJECT="mozilla"

	mercurial_src_unpack

	if use iceweasel; then
		unpack iceweasel-icons-3.0.tar.bz2

		cp -r iceweaselicons/browser mozilla/
	fi

	cd "${S}" || die "could not chdir to ${S}"

	if use iceweasel; then
		sed -i -e "s|Minefield|Iceweasel|" browser/locales/en-US/chrome/branding/brand.* \
			browser/branding/nightly/configure.sh
	fi

	esedpatch "${FILESDIR}/${P}-patches"

	eautoreconf || die "failed  running eautoreconf"
}

src_compile() {
	declare MOZILLA_FIVE_HOME="/usr/$(get_libdir)/${PN}-${SLOT}"
	MEXTENSIONS="default"

	####################################
	#
	# mozconfig, CFLAGS and CXXFLAGS setup
	#
	####################################

	mozconfig_init
	mozconfig_config

	mozconfig_annotate '' --enable-extensions="${MEXTENSIONS}"
	mozconfig_annotate '' --disable-mailnews
	mozconfig_annotate 'broken' --disable-mochitest
	mozconfig_annotate 'broken' --disable-crashreporter
	mozconfig_annotate '' --enable-system-hunspell
	#mozconfig_annotate '' --enable-system-sqlite
	mozconfig_annotate '' --enable-image-encoder=all
	mozconfig_annotate '' --enable-canvas
	mozconfig_annotate '' --with-system-nspr
	mozconfig_annotate '' --with-system-nss
	# mozconfig_annotate '' --enable-system-lcms
	mozconfig_annotate '' --enable-oji --enable-mathml
	mozconfig_annotate 'places' --enable-storage --enable-places --enable-places_bookmarks

	# Other ff-specific settings
	#mozconfig_use_enable mozdevelop jsd
	#mozconfig_use_enable mozdevelop xpctools
	mozconfig_use_extension mozdevelop
	mozconfig_annotate '' --with-default-mozilla-five-home=${MOZILLA_FIVE_HOME}
	if use xulrunner; then
		# Add xulrunner variable
		mozconfig_annotate '' --with-libxul-sdk=/usr/$(get_libdir)/xulrunner-${SLOT}
	fi

	if ! use bindist && ! use iceweasel; then
		mozconfig_annotate '' --enable-official-branding
	fi

	if use qt4 ; then
		mozconfig_annotate '' --enable-default-toolkit=cairo-qt
		mozconfig_annotate '' --disable-system-cairo
		mozconfig_annotate '' --with-qtdir=/usr
	fi


	# Finalize and report settings
	mozconfig_final

	# -fstack-protector breaks us
	if gcc-version ge 4 1; then
		gcc-specs-ssp && append-flags -fno-stack-protector
	else
		gcc-specs-ssp && append-flags -fno-stack-protector-all
	fi
	filter-flags -fstack-protector -fstack-protector-all

	####################################
	#
	#  Configure and build
	#
	####################################

	CPPFLAGS="${CPPFLAGS} -DARON_WAS_HERE" \
	CC="$(tc-getCC)" CXX="$(tc-getCXX)" LD="$(tc-getLD)" \
	econf || die

	# It would be great if we could pass these in via CPPFLAGS or CFLAGS prior
	# to econf, but the quotes cause configure to fail.
	sed -i -e \
		's|-DARON_WAS_HERE|-DGENTOO_NSPLUGINS_DIR=\\\"/usr/'"$(get_libdir)"'/nsplugins\\\" -DGENTOO_NSBROWSER_PLUGINS_DIR=\\\"/usr/'"$(get_libdir)"'/nsbrowser/plugins\\\"|' \
		"${S}"/config/autoconf.mk \
		"${S}"/toolkit/content/buildconfig.html

	# Should the build use multiprocessing? Not enabled by default, as it tends to break
	[ "${WANT_MP}" = "true" ] && jobs=${MAKEOPTS} || jobs="-j1"
	emake ${jobs} || die
}

pkg_preinst() {
	declare MOZILLA_FIVE_HOME="/usr/$(get_libdir)/${PN}-${SLOT}"

	einfo "Removing old installs with some really ugly code.  It potentially"
	einfo "eliminates any problems during the install, however suggestions to"
	einfo "replace this are highly welcome.  Send comments and suggestions to"
	einfo "mozilla@gentoo.org."
	rm -rf "${ROOT}"${MOZILLA_FIVE_HOME}
}

src_install() {
	declare MOZILLA_FIVE_HOME="/usr/$(get_libdir)/${PN}-${SLOT}"

	emake DESTDIR="${D}" install || die "emake install failed"
	rm "${D}"/usr/bin/firefox

	cp "${FILESDIR}"/gentoo-default-prefs.js "${D}"${MOZILLA_FIVE_HOME}/defaults/preferences/all-gentoo.js

	# Install icon and .desktop for menu entry
	if use iceweasel; then
		newicon "${S}"/browser/base/branding/icon48.png iceweasel-icon.png
		newmenu "${FILESDIR}"/icon/iceweasel.desktop \
			mozilla-firefox-${SLOT}.desktop
	elif ! use bindist; then
		newicon "${S}"/other-licenses/branding/firefox/content/icon48.png firefox-icon.png
		newmenu "${FILESDIR}"/icon/mozilla-firefox-1.5.desktop \
			mozilla-firefox-${SLOT}.desktop
		sed -i -e "s/Mozilla Firefox/Mozilla Firefox (${SLOT})/" "${D}"/usr/share/applications/mozilla-firefox-${SLOT}.desktop
	else
		newicon "${S}"/browser/base/branding/icon48.png firefox-icon-unbranded.png
		newmenu "${FILESDIR}"/icon/mozilla-firefox-1.5-unbranded.desktop \
			mozilla-firefox-${SLOT}.desktop
		sed -i -e "s/Bon Echo/Minefield/" "${D}"/usr/share/applications/mozilla-firefox-${SLOT}.desktop
	fi
	
	sed -i -e "s|/usr/bin/firefox|/usr/bin/firefox-${SLOT}|g" "${D}"/usr/share/applications/mozilla-firefox-${SLOT}.desktop

		# Create /usr/bin/firefox
		cat <<EOF >"${D}"/usr/bin/firefox-${SLOT}
#!/bin/sh
export LD_LIBRARY_PATH="/usr/$(get_libdir)/mozilla-firefox-${SLOT}"
exec /usr/$(get_libdir)/mozilla-firefox-${SLOT}/firefox "\$@"
EOF
		fperms 0755 /usr/bin/firefox-${SLOT}
}

pkg_postinst() {
	declare MOZILLA_FIVE_HOME="/usr/$(get_libdir)/${PN}-${SLOT}"

	ewarn "All the packages built against ${PN} won't compile,"
	ewarn "if after installing firefox ${SLOT} you get some blockers,"
	ewarn "please add 'xulrunner' to your USE-flags."

	# Update mimedb for the new .desktop file
	fdo-mime_desktop_database_update
}
