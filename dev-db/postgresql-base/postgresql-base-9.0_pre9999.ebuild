# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-db/postgresql-base/postgresql-base-9.0_beta2-r1.ebuild,v 1.2 2010/06/20 13:26:58 patrick Exp $

EAPI="2"

WANT_AUTOMAKE="none"

inherit eutils git multilib versionator autotools

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd"

DESCRIPTION="PostgreSQL libraries and clients"
HOMEPAGE="http://www.postgresql.org/"

MY_PV=${PV/_/}
#SRC_URI="mirror://postgresql/source/v${MY_PV}/postgresql-${MY_PV}.tar.bz2"
EGIT_REPO_URI="git://git.postgresql.org/git/postgresql.git"
S=${WORKDIR}/postgresql-${MY_PV}

LICENSE="POSTGRESQL"
SLOT="$(get_version_component_range 1-2)"
IUSE_LINGUAS="
	linguas_af linguas_cs linguas_de linguas_es linguas_fa linguas_fr
	linguas_hr linguas_hu linguas_it linguas_ko linguas_nb linguas_pl
	linguas_pt_BR linguas_ro linguas_ru linguas_sk linguas_sl linguas_sv
	linguas_tr linguas_zh_CN linguas_zh_TW"
IUSE="doc kerberos nls pam readline ssl threads zlib ldap pg_legacytimestamp ${IUSE_LINGUAS}"
RESTRICT="test"

wanted_languages() {
	for u in ${IUSE_LINGUAS} ; do
		use $u && echo -n "${u#linguas_} "
	done
}

RDEPEND="kerberos? ( virtual/krb5 )
	pam? ( virtual/pam )
	readline? ( >=sys-libs/readline-4.1 )
	ssl? ( >=dev-libs/openssl-0.9.6-r1 )
	zlib? ( >=sys-libs/zlib-1.1.3 )
	>=app-admin/eselect-postgresql-0.3
	virtual/libintl
	!!dev-db/postgresql-libs
	!!dev-db/postgresql-client
	!!dev-db/libpq
	!!dev-db/postgresql
	ldap? ( net-nds/openldap )"
DEPEND="${RDEPEND}
	sys-devel/flex
	>=sys-devel/bison-1.875
	nls? ( sys-devel/gettext )"
PDEPEND="doc? ( ~dev-db/postgresql-docs-${PV} )"

src_prepare() {
	epatch "${FILESDIR}/postgresql-${SLOT}-common.patch" \
		"${FILESDIR}/postgresql-${SLOT}-base.patch"

	if use kerberos && has_version "<app-crypt/heimdal-1.3.2-r1" ; then
		"${FILESDIR}/postgresql-base-8.4-9.0-heimdal_strlcpy.patch"
	fi

	# to avoid collision - it only should be installed by server
	rm "${S}/src/backend/nls.mk"

	# because psql/help.c includes the file
	ln -s "${S}/src/include/libpq/pqsignal.h" "${S}/src/bin/psql/"
	cd "${S}"
	eautoconf
}

src_configure() {
	export LDFLAGS_SL="${LDFLAGS}"
	econf --prefix=/usr/$(get_libdir)/postgresql-${SLOT} \
		--datadir=/usr/share/postgresql-${SLOT} \
		--docdir=/usr/share/doc/postgresql-${SLOT} \
		--sysconfdir=/etc/postgresql-${SLOT} \
		--includedir=/usr/include/postgresql-${SLOT} \
		--mandir=/usr/share/postgresql-${SLOT}/man \
		--enable-depend \
		--without-tcl \
		--without-perl \
		--without-python \
		$(use_with readline) \
		$(use_with kerberos krb5) \
		$(use_with kerberos gssapi) \
		"$(use_enable nls nls "$(wanted_languages)")" \
		$(use_with pam) \
		$(use_enable !pg_legacytimestamp integer-datetimes ) \
		$(use_with ssl openssl) \
		$(use_enable threads thread-safety) \
		$(use_with zlib) \
		$(use_with ldap) \
		|| die "configure failed"
}

src_compile() {
	emake || die "emake failed"

	cd "${S}/contrib"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	insinto /usr/include/postgresql-${SLOT}/postmaster
	doins "${S}"/src/include/postmaster/*.h
	dodir /usr/share/postgresql-${SLOT}/man/man1
	tar -zxf "${S}/doc/man.tar.gz" -C "${D}"/usr/share/postgresql-${SLOT}/man man1/{ecpg,pg_config}.1

	rm -r "${D}/usr/share/doc/postgresql-${SLOT}/html"
	rm "${D}/usr/share/postgresql-${SLOT}/man/man1"/{initdb,ipcclean,pg_controldata,pg_ctl,pg_resetxlog,pg_restore,postgres,postmaster}.1
	dodoc README HISTORY doc/{README.*,TODO,bug.template}

	cd "${S}/contrib"
	emake DESTDIR="${D}" install || die "emake install failed"
	cd "${S}"

	dodir /etc/eselect/postgresql/slots/${SLOT}

	IDIR="/usr/include/postgresql-${SLOT}"
	cat > "${D}/etc/eselect/postgresql/slots/${SLOT}/base" <<-__EOF__
postgres_ebuilds="\${postgres_ebuilds} ${PF}"
postgres_prefix=/usr/$(get_libdir)/postgresql-${SLOT}
postgres_datadir=/usr/share/postgresql-${SLOT}
postgres_bindir=/usr/$(get_libdir)/postgresql-${SLOT}/bin
postgres_symlinks=(
	${IDIR} /usr/include/postgresql
	${IDIR}/libpq-fe.h /usr/include/libpq-fe.h
	${IDIR}/pg_config_manual.h /usr/include/pg_config_manual.h
	${IDIR}/libpq /usr/include/libpq
	${IDIR}/postgres_ext.h /usr/include/postgres_ext.h
)
__EOF__

	cat >"${T}/50postgresql-94-${SLOT}" <<-__EOF__
		LDPATH=/usr/$(get_libdir)/postgresql-${SLOT}/$(get_libdir)
		MANPATH=/usr/share/postgresql-${SLOT}/man
	__EOF__
	doenvd "${T}/50postgresql-94-${SLOT}"

	keepdir /etc/postgresql-${SLOT}
}

pkg_postinst() {
	eselect postgresql update
	[[ "$(eselect postgresql show)" = "(none)" ]] && eselect postgresql set ${SLOT}
	elog "If you need a global psqlrc-file, you can place it in:"
	elog "    '${ROOT}/etc/postgresql-${SLOT}/'"
	elog
	elog "The PostgreSQL community has called for more testers of the upcoming 9.0"
	elog "release. This beta version of the PostgreSQL client applications and libraries,"
	elog "while moved to ~arch, will never be marked stable. As such, you may not want to"
	elog "use this package in an environment where incompatible changes are"
	elog "unacceptable. Bear in mind, though, that these packages are slotted and that you"
	elog "may have multiple installations simultaneously without conflict. However, you"
	elog "may only use one set of client applications and libraries via 'eselect'."
}

pkg_postrm() {
	eselect postgresql update
}
