# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: Exp $

WANT_AUTOCONF="2.1"
inherit flag-o-matic toolchain-funcs eutils mozconfig-3 makeedit multilib mercurial cvs java-pkg-opt-2 python autotools
PATCH="${P}-patches-0.1"

DESCRIPTION="Mozilla runtime package that can be used to bootstrap XUL+XPCOM applications"
HOMEPAGE="http://developer.mozilla.org/en/docs/XULRunner"
SRC_URI="mirror://gentoo/${PATCH}.tar.bz2"

KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86"
SLOT="scm"
LICENSE="|| ( MPL-1.1 GPL-2 LGPL-2.1 )"
IUSE="qt4"

RDEPEND="java? ( >=virtual/jre-1.4 )
	qt? ( x11-libs/qt-gui:4.4 )
	>=sys-devel/binutils-2.16.1
	>=dev-libs/nss-3.12
	>=dev-libs/nspr-4.7.1
	>=app-text/hunspell-1.1.9
	>=media-libs/lcms-1.17"

DEPEND="java? ( >=virtual/jdk-1.4 )
	${RDEPEND}
	dev-util/pkgconfig"

S=${WORKDIR}/mozilla-central

# Needed by src_compile() and src_install().
# Would do in pkg_setup but that loses the export attribute, they
# become pure shell variables.
export MOZ_CO_PROJECT=xulrunner
export BUILD_OFFICIAL=1
export MOZILLA_OFFICIAL=1

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
	java-pkg-opt-2_pkg_setup
}

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

src_unpack() {

	EHG_REPO_URI="http://hg.mozilla.org/mozilla-central/"
	HG_PROJECT="mozilla"

	mercurial_src_unpack

	cd "${S}" || die "could not chdir to ${S}"

	esedpatch "${FILESDIR}/${P}-patches"

	eautoreconf || die "failed  running eautoreconf"
}

src_compile() {
	declare MOZILLA_FIVE_HOME="/usr/$(get_libdir)/${PN}-${SLOT}"

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
	#mozconfig_annotate '' --enable-js-binary
	mozconfig_annotate '' --enable-embedding-tests
	mozconfig_annotate '' --with-system-nspr
	mozconfig_annotate '' --with-system-nss
	# mozconfig_annotate '' --enable-system-lcms
	mozconfig_annotate '' --with-system-bz2
	# Bug 60668: Galeon doesn't build without oji enabled, so enable it
	# regardless of java setting.
	mozconfig_annotate '' --enable-oji --enable-mathml
	mozconfig_annotate 'places' --enable-storage --enable-places --enable-places_bookmarks
	mozconfig_annotate '' --enable-safe-browsing

	# Other ff-specific settings
	mozconfig_annotate '' --enable-jsd
	mozconfig_annotate '' --enable-xpctools
	mozconfig_annotate '' --disable-libxul
	mozconfig_annotate '' --with-default-mozilla-five-home=${MOZILLA_FIVE_HOME}

	#disable java
	if ! use java ; then
		mozconfig_annotate '-java' --disable-javaxpcom
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

	emake || die "emake failed"
}

src_install() {
	declare MOZILLA_FIVE_HOME="/usr/$(get_libdir)/${PN}-${SLOT}"

	emake DESTDIR="${D}" install || die "emake install failed"

	rm "${D}"/usr/bin/xulrunner

	dodir /usr/bin
	dosym ${MOZILLA_FIVE_HOME}/xulrunner /usr/bin/xulrunner-${SLOT}

	# Add vendor
	echo "pref(\"general.useragent.vendor\",\"Gentoo\");" \
		>> "${D}"${MOZILLA_FIVE_HOME}/defaults/pref/vendor.js

	if use java ; then
	    java-pkg_dojar "${D}"${MOZILLA_FIVE_HOME}/javaxpcom.jar
	    rm -f "${D}"${MOZILLA_FIVE_HOME}/javaxpcom.jar
	fi
}
