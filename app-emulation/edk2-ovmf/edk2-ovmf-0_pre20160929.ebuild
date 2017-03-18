# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=6

PYTHON_COMPAT=( python2_7 )

inherit eutils git-r3 flag-o-matic python-single-r1

_OPENSSL_VERSION="1.0.2j"
_COMPILER="GCC49"
MY_PN=${PN/-/.}
DESCRIPTION="UEFI Firmware (OVMF) with Secure Boot Support - for Virtual Machines (QEMU) - from Tianocore EDK2"
HOMEPAGE="https://tianocore.github.io/ovmf/"
SRC_URI="https://www.openssl.org/source/openssl-${_OPENSSL_VERSION}.tar.gz"
EGIT_REPO_URI="https://github.com/tianocore/edk2.git"
EGIT_COMMIT="ed72804638c9b240477c5235d72c3823483813b2"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	dev-lang/nasm
	sys-power/iasl"
RDEPEND=""

RESTRICT="strip"

_UDK_DIR="${S}"
EDK_TOOLS_PATH="${_UDK_DIR}/BaseTools"
_UDK_OVMF_X64_PKG="OvmfX64"
_UDK_OVMF_X64_DSC="OvmfPkg/OvmfPkgX64.dsc"

_UDK_OVMF_IA32_PKG="OvmfIa32"
_UDK_OVMF_IA32_DSC="OvmfPkg/OvmfPkgIa32.dsc"

_UDK_TARGET="RELEASE"

src_unpack() {
	git-r3_src_unpack
	unpack ${A}
}

src_prepare() {
	cd "${_UDK_DIR}/" || die

	if [ -e "${_UDK_DIR}/Build" ]; then
		rm -r "${_UDK_DIR}/Build/" || die
	fi
	if [ -e "${_UDK_DIR}/Conf" ]; then
		rm -r "${_UDK_DIR}/Conf/" || die
	fi
	mkdir -p "${_UDK_DIR}/Conf/" || die
	mkdir -p "${_UDK_DIR}/Build/" || die

	elog "Use python2 for UDK BaseTools"
	sed 's|python |python2 |g' -i "${EDK_TOOLS_PATH}/BinWrappers/PosixLike"/* || die
	sed 's|python |python2 |g' -i "${EDK_TOOLS_PATH}/Tests/GNUmakefile" || die

	sed 's|-Werror |-Wno-error -Wno-unused-but-set-variable |g' \
		-i "${EDK_TOOLS_PATH}/Source/C/Makefiles/header.makefile" || die
	sed 's|-Werror |-Wno-error -Wno-unused-but-set-variable |g' \
		-i "${EDK_TOOLS_PATH}/Conf/tools_def.template" || die

	sed 's|DEFINE GCC_ALL_CC_FLAGS            = -g |DEFINE GCC_ALL_CC_FLAGS            = -O0 -mabi=ms -maccumulate-outgoing-args |g' -i "${EDK_TOOLS_PATH}/Conf/tools_def.template" || die
	sed 's|DEFINE GCC44_ALL_CC_FLAGS            = -g |DEFINE GCC44_ALL_CC_FLAGS            = -O0 -mabi=ms -maccumulate-outgoing-args |g' -i "${EDK_TOOLS_PATH}/Conf/tools_def.template" || die

	sed 's|DEFINE GCC_DLINK_FLAGS_COMMON      = |DEFINE GCC_DLINK_FLAGS_COMMON      = -Wl,-fuse-ld=bfd |g' -i "${EDK_TOOLS_PATH}/Conf/tools_def.template" || die
	sed 's|DEFINE GCC44_IA32_X64_DLINK_COMMON   = |DEFINE GCC44_IA32_X64_DLINK_COMMON   = -Wl,-fuse-ld=bfd |g' -i "${EDK_TOOLS_PATH}/Conf/tools_def.template" || die
	sed 's|DEFINE GCC49_IA32_X64_DLINK_COMMON   = |DEFINE GCC49_IA32_X64_DLINK_COMMON   = -Wl,-fuse-ld=bfd |g' -i "${EDK_TOOLS_PATH}/Conf/tools_def.template" || die

	sed "s|ACTIVE_PLATFORM       = Nt32Pkg/Nt32Pkg.dsc|ACTIVE_PLATFORM       = ${_UDK_OVMF_X64_DSC}|g" -i "${EDK_TOOLS_PATH}/Conf/target.template" || die
	sed "s|TARGET                = DEBUG|TARGET                = ${_UDK_TARGET}|g" -i "${EDK_TOOLS_PATH}/Conf/target.template" || die
 	sed "s|TOOL_CHAIN_TAG        = MYTOOLS|TOOL_CHAIN_TAG        = ${_COMPILER}|g" -i "${EDK_TOOLS_PATH}/Conf/target.template" || die
	sed "s|IA32|X64|g" -i "${EDK_TOOLS_PATH}/Conf/target.template" || true

	chmod 0755 "${_UDK_DIR}/BaseTools/BuildEnv" || die

	mv "${WORKDIR}/openssl-${_OPENSSL_VERSION}" "${_UDK_DIR}/CryptoPkg/Library/OpensslLib/" || die
	cd "${_UDK_DIR}/CryptoPkg/Library/OpensslLib/openssl-${_OPENSSL_VERSION}/" || die
	patch -p1 -i "${_UDK_DIR}/CryptoPkg/Library/OpensslLib/EDKII_openssl-${_OPENSSL_VERSION}.patch" || die

	cd "${_UDK_DIR}/CryptoPkg/Library/OpensslLib/" || die
	chmod 0755 "${_UDK_DIR}/CryptoPkg/Library/OpensslLib/Install.sh" || die

	eapply_user
}

src_configure() {
	cd "${_UDK_DIR}/CryptoPkg/Library/OpensslLib/" || die
	"${_UDK_DIR}/CryptoPkg/Library/OpensslLib/Install.sh" || die
	strip-flags
}

src_compile() {
	cd "${_UDK_DIR}/" || die
	source "${_UDK_DIR}/BaseTools/BuildEnv" BaseTools
	export ARCH=X64
	export EDK_TOOLS_PATH="${EDK_TOOLS_PATH}"
	emake -j1 -C "${EDK_TOOLS_PATH}"
	export LDFLAGS="${LDFLAGS} -Wl,-fuse-ld=bfd"
	export CFLAGS="${CFLAGS} -Wl,-fuse-ld=bfd"
	"${_UDK_DIR}/OvmfPkg/build.sh" -a "X64" -b "${_UDK_TARGET}" -D "SECURE_BOOT_ENABLE=TRUE" -D "FD_SIZE_2MB" --enable-flash || die
}

src_install() {
	dodir "/usr/share/ovmf/x64/"
	insinto "/usr/share/ovmf/x64/"
    newins "${_UDK_DIR}/Build/${_UDK_OVMF_X64_PKG}/${_UDK_TARGET}_${_COMPILER}/FV/OVMF.fd" "ovmf_x64.bin"
    newins "${_UDK_DIR}/Build/${_UDK_OVMF_X64_PKG}/${_UDK_TARGET}_${_COMPILER}/FV/OVMF_CODE.fd" "ovmf_code_x64.bin"
    newins "${_UDK_DIR}/Build/${_UDK_OVMF_X64_PKG}/${_UDK_TARGET}_${_COMPILER}/FV/OVMF_VARS.fd" "ovmf_vars_x64.bin"
}
