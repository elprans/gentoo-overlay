DESCRIPTION="pyexiv2, a python binding to exiv2"
HOMEPAGE="http://tilloy.net/dev/pyexiv2/"
SRC_URI="http://tilloy.net/dev/pyexiv2/releases/${PN}-${PV}.tar.bz2"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~sparc-fbsd ~x86 ~x86-fbsd"
IUSE=""
DEPEND="dev-lang/python
	dev-util/scons
	media-gfx/exiv2
	dev-libs/boost"
RDEPEND="${DEPEND}"

src_unpack() {
	unpack ${A}
}

src_compile() {
	scons || die "emake install failed"
}

src_install() {
	scons DESTDIR="${D}" install || die "emake install failed"
	dodoc ${S}/README
}

