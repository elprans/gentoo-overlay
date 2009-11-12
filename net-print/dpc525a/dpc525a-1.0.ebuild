# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit rpm versionator

DESCRIPTION="Drivers for Fuji Xerox Docuprint C525A"
HOMEPAGE="http://www.fujixerox.com.au/localDriver.do?product_code=307"
SRC_URI="ftp://ftp.fxa.com.au/drivers/dpc525a/dpc525a_linux_.0.0.tar.zip"

LICENSE="Fuji Xerox"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

DEPEND=""
RDEPEND="net-print/cups"

function src_unpack() {
	unpack "${A}"
	cd "${WORKDIR}/C525A_LinuxE"
	rpm_unpack "./Fuji_Xerox-DocuPrint_C525_A_AP-${PV}-1.i386.rpm"
}

function src_prepare() {
	local d="${WORKDIR}/C525A_LinuxE/usr/share/cups/model/FujiXerox/en/"
	
	sed -i -e "s|/usr/lib/cups|/usr/libexec/cups|g" \
		   -e "s|Manufacturer: \"FX\"|Manufacturer: \"Xerox\"|g" \
			"${d}/FX_DocuPrint_C525_A_AP.ppd"
}

function src_install() {
	local d="${WORKDIR}/C525A_LinuxE"

	insinto "/usr/libexec/"
	chmod +x ${d}/usr/lib/cups/filter/*
	INSOPTIONS="-m 755" doins -r "${d}/usr/lib/cups/"
	insinto "/usr/share/ppd/Xerox/"
	gzip -f -9 "${d}/usr/share/cups/model/FujiXerox/en/FX_DocuPrint_C525_A_AP.ppd"
	newins "${d}/usr/share/cups/model/FujiXerox/en/FX_DocuPrint_C525_A_AP.ppd.gz" "Xerox-DocuPrint_C525A.ppd.gz"
	insinto "/usr/share/cups/FujiXerox/"
	doins -r "${d}/usr/share/cups/FujiXerox/dlut/"
}
