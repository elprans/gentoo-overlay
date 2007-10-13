PHP_EXT_NAME="ZendDebugger"
PHP_EXT_INI="yes"
PHP_EXT_ZENDEXT="yes"

inherit php-ext-base-r1

KEYWORDS="~x86 ~amd64"

MY_PV="${PV/_/}"
MY_PV="${MY_PV/rc/RC}"

MY_BASE_URL="http://downloads.zend.com/pdt/server-debugger/"

MY_ARCH=${ARCH/x86/glibc21-i386}
MY_ARCH=${MY_ARCH/amd64/glibc23-x86_64}

S="${WORKDIR}/${PN}-${PV}-linux-${MY_ARCH}"

SRC_URI="amd64? (${MY_BASE_URL}/${PN}-${MY_PV}-linux-${MY_ARCH}.tar.gz)
		 x86? (${MY_BASE_URL}/${PN}-${MY_PV}-linux-${MY_ARCH}.tar.gz)"

DESCRIPTION="A PHP Debugger from Zend"
HOMEPAGE="http://www.zend.com/"
LICENSE="ZendDebugger"
SLOT="0"
IUSE=""

RESTRICT="mirror strip"

need_php_by_category

pkg_setup() {
	php_binary_extension
	QA_TEXTRELS="${EXT_DIR/\//}/${PHP_EXT_NAME}.so"
	QA_EXECSTACK="${EXT_DIR/\//}/${PHP_EXT_NAME}.so"
}

src_install() {
	php-ext-base-r1_src_install

	# Detect which PHP5 version is installed
	if has_version =dev-lang/php-5.1* ; then
		ZEND_VERSION_DIR="5_1_x_comp"
	elif has_version =dev-lang/php-5.2* ; then
		ZEND_VERSION_DIR="5_2_x_comp"
	else
		die "Unable to find an installed dev-lang/php-5* package."
	fi

	insinto "${EXT_DIR}"
	doins "${ZEND_VERSION_DIR}/${PHP_EXT_NAME}.so" || 
				die "Could not install ${PHP_EXT_NAME}.so"

	dodoc-php README
	dodoc-php dummy.php

	php-ext-base-r1_addtoinifiles "zend_debugger.connect_password" ''
	php-ext-base-r1_addtoinifiles "zend_debugger.allow_hosts" '"127.0.0.1"'
	php-ext-base-r1_addtoinifiles "zend_debugger.deny_hosts" ''
	php-ext-base-r1_addtoinifiles "zend_debugger.connector_port" '"10000"'
	php-ext-base-r1_addtoinifiles "zend_debugger.expose_remotely" '"allowed_hosts"'
	php-ext-base-r1_addtoinifiles "zend_debugger.allow_tunnel" ''
}

pkg_postinst() {
	has_php

	# You only need to restart apache2 if you're using mod_php
	if built_with_use =${PHP_PKG} apache2 ; then
		elog
		elog "You need to restart apache2 to activate the ${PN}."
		elog
	fi
}

