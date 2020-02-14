# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit multiprocessing rpm

DESCRIPTION="A beautiful cross platform Desktop Player for Google Play Music"
HOMEPAGE="https://www.googleplaymusicdesktopplayer.com/"
MY_PV="${PV//_/-}"
THEIR_PN="google-play-music-desktop-player"
THEIR_PV="4.6.1"

ELECTRON_V=3.1.8
ELECTRON_SLOT=3.1

SRC_URI="
	https://github.com/MarshallOfSound/Google-Play-Music-Desktop-Player-UNOFFICIAL-/releases/download/v${PV}/${THEIR_PN}-${THEIR_PV}.x86_64.rpm
"

RESTRICT="mirror"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="
	>=dev-util/electron-${ELECTRON_V}:${ELECTRON_SLOT}"
RDEPEND="
	${DEPEND}
"

S="${WORKDIR}/${PN}-${MY_PV}"

get_install_dir() {
	echo -n "/usr/$(get_libdir)/google-music"
}

get_electron_dir() {
	echo -n "/usr/$(get_libdir)/electron-${ELECTRON_SLOT}"
}

src_unpack() {
	local a
	local install_dir="$(get_install_dir)"

	for a in ${A} ; do
		case ${a} in
		*.rpm) srcrpm_unpack "${a}" ;;
		*) unpack "${a}" ;;
		esac
	done

	mkdir "${S}" || die
	mv "${WORKDIR}/usr" "${S}" || die
	cp "${FILESDIR}/${PN}.sh" "${S}/${PN}" || die
	cd "${S}" || die
}

src_prepare() {
	sed -i -e "s|{{ELECTRON_PATH}}|$(get_electron_dir)/electron|g" \
		./"${PN}" \
		|| die

	sed -i -e "s|{{APP_RESOURCE_PATH}}|$(get_install_dir)/app.asar|g" \
		./"${PN}" \
		|| die

	sed -i -e "s/${THEIR_PN}/${PN}/g" \
		"usr/share/applications/${THEIR_PN}.desktop"

	eapply_user
}

src_install() {
	local install_dir="$(get_install_dir)"

	cd "${S}" || die

	insinto "${install_dir}"

	doins "usr/share/${THEIR_PN}/resources/app.asar"
	insinto /usr/share/applications/
	newins "usr/share/applications/${THEIR_PN}.desktop" "${PN}.desktop"

	insinto /usr/share/icons/
	newins "usr/share/pixmaps/${THEIR_PN}.png" "${PN}.png"

	dobin "${PN}"
}
