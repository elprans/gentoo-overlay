# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"

inherit rpm versionator

MY_PV="$(replace_version_separator $(get_last_version_component_index) '-')"
DESCRIPTION="Drivers for Brother MFU 9840cdw"
HOMEPAGE="http://solutions.brother.com/linux/en_us/"
SRC_URI="http://www.brother.com/pub/bsc/linux/dlf/mfc9840cdwlpr-${MY_PV}.i386.rpm
			http://www.brother.com/pub/bsc/linux/dlf/mfc9840cdwcupswrapper-${MY_PV}.i386.rpm
			http://www.brother.com/pub/bsc/linux/dlf/BR9840_2_GPL.ppd.gz
			scanner? ( http://www.brother.com/pub/bsc/linux/dlf/brscan3-0.2.11-5.x86_64.rpm )"

LICENSE="Brother"
SLOT="0"
KEYWORDS="amd64"
IUSE="scanner"

DEPEND=""
RDEPEND="
	dev-libs/libusb-compat
	net-print/cups
	scanner? ( media-gfx/sane-backends )
"

src_prepare() {
	local d="${WORKDIR}/usr/local/Brother/Printer/mfc9840cdw"
	local s="${d}/cupswrapper/cupswrapperSetup_mfc9840cdw"

	awk -- "/cat <<!ENDOFWFILTER!/ {doprint=1; getline}
	        /^!ENDOFWFILTER!/ {doprint=0}
			{if (doprint)
				print>\"${WORKDIR}/brlpdwrappermfc9840cdw\"}" "${s}" 

	sed -i -e "s|\${printer_model}|mfc9840cdw|g" \
	       -e "s|/usr/local/Brother/Printer|/usr/libexec|g" \
	          "${WORKDIR}/brlpdwrappermfc9840cdw"

	sed -i -e "s|/usr/local/Brother/Printer|/usr/libexec|g" \
	          "$d/lpd/filtermfc9840cdw"
}

src_install() {
	local d="${WORKDIR}/usr/local/Brother/Printer/mfc9840cdw"

	insinto "/usr/libexec/${PN}/cupswrapper/"
	doins -r "${d}/cupswrapper/brcupsconfcl1"
	insinto "/usr/libexec/${PN}"
	doins -r "${d}/lpd"
	doins -r "${d}/inf"
	insinto "/usr/libexec/cups/filter"
	doins "${WORKDIR}/brlpdwrappermfc9840cdw"

	insinto "/usr/bin"
	dobin "${WORKDIR}/usr/bin/bprintconf_mfc9840cdw"

	insinto "/usr/share/ppd/Brother/"
	newins "BR9840_2_GPL.ppd" "Brother-MFC-9840cdw.ppd"

	insinto "/usr/lib64"
	cp -a "${WORKDIR}/usr/lib64/" "${D}/usr/"

	insinto "/usr/local/"
	doins -r "${WORKDIR}/usr/local/Brother"

	dosym "/usr/local/Brother/sane/brsaneconfig3" "/usr/bin/brsaneconfig3"
	chmod +x "${D}/usr/local/Brother/sane/brsaneconfig3"
}