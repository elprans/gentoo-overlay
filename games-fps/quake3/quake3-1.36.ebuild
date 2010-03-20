# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-fps/quake3/quake3-1.36.ebuild,v 1.8 2008/01/12 02:53:11 mr_bones_ Exp $

EAPI=2
inherit flag-o-matic toolchain-funcs eutils games

MY_PV="1.36"
MY_P=io${PN}-${MY_PV}
SRC_URI="http://ioquake3.org/files/${MY_PV}/${MY_P}.tar.bz2"
S=${WORKDIR}/${MY_P}

DESCRIPTION="Quake III Arena - 3rd installment of the classic id 3D first-person shooter"
HOMEPAGE="http://ioquake3.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86 ~x86-fbsd"
IUSE="curl dedicated mumble openal opengl smp speex teamarena voice vorbis"

UIDEPEND="virtual/opengl
	media-libs/openal
	vorbis? ( media-libs/libogg media-libs/libvorbis )
	media-libs/libsdl"
DEPEND="opengl? ( ${UIDEPEND} )
	!dedicated? ( ${UIDEPEND} )"
RDEPEND="${DEPEND}
	games-fps/quake3-data
	teamarena? ( games-fps/quake3-teamarena )
	curl? ( net-misc/curl )
	voice? (
		speex? ( media-libs/speex )
		mumble? ( media-sound/mumble )
	)"

src_prepare() {
	cd "${WORKDIR}"
	sed -i \
		-e '/ALDRIVER_DEFAULT/s/libopenal.so.0/libopenal.so/' \
		"${MY_P}"/code/client/snd_openal.c \
		|| die "sed failed"
}

src_compile() {
	filter-flags -mfpmath=sse
	buildit() { use $1 && echo 1 || echo 0 ; }
	env -u ARCH emake \
		BUILD_SERVER=$(buildit dedicated) \
		BUILD_CLIENT=$(( $(buildit opengl) | $(buildit !dedicated) )) \
		BUILD_CLIENT_SMP=$(buildit smp) \
		USE_OPENAL=$(buildit openal) \
		USE_OPENAL_DLOPEN=$(buildit openal) \
		USE_CURL=$(buildit curl) \
		USE_CURL_DLOPEN=$(buildit curl) \
		USE_CODEC_VORBIS=$(buildit vorbis) \
		TEMPDIR="${T}" \
		OPTIMIZE="${CFLAGS}" \
		USE_LOCAL_HEADERS=0 \
		USE_VOIP=$(buildit voice) \
		USE_INTERNAL_SPEEX=$(buildit !speex) \
		USE_MUMBLE=$(buildit mumble) \
		DEFAULT_BASEDIR="${GAMES_DATADIR}/quake3" \
		DEFAULT_LIBDIR="$(games_get_libdir)/quake3" \
		|| die "emake failed"
}

src_install() {
	dodoc TODO README BUGS ChangeLog

	if use opengl ; then
	   doicon quake3.png
	   if use smp; then
		  make_desktop_entry quake3-smp "Quake III Arena (SMP)"
		 else
		  make_desktop_entry quake3 "Quake III Arena"
	   fi
	fi

	cd build/release*
	local old_x x
	for old_x in ioq* ; do
		x=${old_x%.*}
		newgamesbin ${old_x} ${x} || die "newgamesbin ${x}"
		dosym ${x} "${GAMES_BINDIR}"/${x/io}
	done
	exeinto "$(games_get_libdir)"/${PN}/baseq3
	doexe baseq3/*.so || die "baseq3 .so"
	exeinto "$(games_get_libdir)"/${PN}/missionpack
	doexe missionpack/*.so || die "missionpack .so"

	prepgamesdirs
}

pkg_postinst() {
	games_pkg_postinst
	ewarn "The source version of Quake 3 will not work with Punk Buster."
	ewarn "If you need pb support, then use the quake3-bin package."
	echo
}
