# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/shntool/shntool-2.0.3.ebuild,v 1.2 2005/06/09 00:55:29 mr_bones_ Exp $

IUSE="flac sox shorten wavpack alac"

DESCRIPTION="shntool is a multi-purpose WAVE data processing and reporting utility"
HOMEPAGE="http://shnutils.freeshell.org/shntool/"
SRC_URI="http://shnutils.freeshell.org/shntool/dist/src/${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~ppc ~amd64 ~sparc"

DEPEND="shorten? ( >=media-sound/shorten-3.5.1 )
	flac? ( >=media-libs/flac-1.1.0 )
	sox? ( >=media-sound/sox-12.17.4 )
	wavpack? ( >=media-sound/wavpack-4.1 )
	alac? ( >=media-sound/alac_decoder-0.1.1 )"

src_compile() {
	formats=wav
	if use shorten; then
		formats="${formats},shn"
	fi
	if use flac; then
		formats="${formats},flac"
	fi
	if use sox; then
		formats="${formats},sox"
	fi
	if use wavpack; then
		formats="${formats},wv"
	fi
	if use alac; then
		formats="${formats},alac"
	fi

	econf --with-formats="${formats}" || die "configure failed"
	emake || die "make failed"
}

src_install () {
	einstall || die
	dodoc doc/*
}
