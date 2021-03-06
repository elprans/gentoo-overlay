# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

# Most of the content of the ebuild has been adapted from
# app-emulation/dxvk – speficically, from telans' overlay
# as unsurprisingly the build process is almost identical

MULTILIB_COMPAT=( abi_x86_{32,64} )

inherit meson multilib-minimal toolchain-funcs
if [[ "${PV}" == "9999" ]]; then
	inherit git-r3
fi

DESCRIPTION="Proton's Direct3D 12 implementation, forked from VKD3D"
HOMEPAGE="https://github.com/HansKristian-Work/vkd3d-proton"
if [[ "${PV}" == "9999" ]]; then
	EGIT_REPO_URI="https://github.com/HansKristian-Work/vkd3d-proton.git"
	VKD3D_COMMIT="git describe"
else
	DXIL_SPIRV_COMMIT="21fb9d8c7b98cf3923f388d4845d113fd18daccf"
	VKD3D_COMMIT="3ed3526332f53d7"
	SRC_URI="https://github.com/HansKristian-Work/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
		https://github.com/HansKristian-Work/dxil-spirv/archive/${DXIL_SPIRV_COMMIT}.tar.gz -> ${PN}-dxil-spirv-${DXIL_SPIRV_COMMIT}.tar.gz"
fi

LICENSE="LGPL-2.1"
SLOT="0"
RESTRICT="test strip"

if [[ "${PV}" == "9999" ]]; then
	KEYWORDS=""
else
	KEYWORDS="~amd64"
fi

DEPEND="
	dev-util/glslang
	>=dev-util/spirv-headers-1.5.4.2_pre20210327
	>=dev-util/vulkan-headers-1.2.170
"
RDEPEND="
	media-libs/vulkan-loader[${MULTILIB_USEDEP}]
	>=media-libs/mesa-19.2
	|| (
		>=app-emulation/wine-staging-4.5[${MULTILIB_USEDEP},vulkan]
		>=app-emulation/wine-vanilla-4.5[${MULTILIB_USEDEP},vulkan]
	)
"
RDEPEND="${DEPEND}"

PATCHES=(
	"${FILESDIR}/0001-build-fixes.patch"
)

bits() { [[ ${ABI} = amd64 ]] && echo 64 || echo 32; }

vkd3d-proton_check_mingw() {
	local -a categories
	use abi_x86_64 && categories+=("cross-x86_64-w64-mingw32")
	use abi_x86_32 && categories+=("cross-i686-w64-mingw32")

	# Check if pthread is enabled on mingw toolchains. (from tastytea's overlay)
	local thread_model="$(LC_ALL=C ${categories//cross-/}-gcc -v 2>&1 \
								| grep 'Thread model' | cut -d' ' -f3)"

	for cat in ${categories[@]}; do
		if ! has_version -b "${cat}/mingw64-runtime[libraries]" ||
				! has_version -b "${cat}/gcc" ||
				[[ "${thread_model}" != "posix" ]]; then
			eerror "The ${cat} toolchain is not properly installed."
			eerror "Make sure to install ${cat}/gcc with:"
			eerror "EXTRA_ECONF=\"--enable-threads=posix --disable-sjlj-exceptions --with-dwarf2\""
			eerror "and ${cat}/mingw64-runtime with USE=\"libraries\"."
			einfo
			einfo "For a short guide please go to the link below.:"
			einfo "<https://gitlab.com/TheGreatMcPain/thegreatmcpain-overlay/-/tree/master/app-emulation#setting-up-mingw-in-gentoo>"
			einfo
			die "${cat} toolchain required."
		fi
	done
}

pkg_pretend() {
	vkd3d-proton_check_mingw
}

pkg_setup() {
	vkd3d-proton_check_mingw
}

src_unpack() {
	default

	if [[ "${PV}" != "9999" ]]; then
		rmdir "${S}/subprojects/dxil-spirv" || die
		mv "${WORKDIR}/dxil-spirv-${DXIL_SPIRV_COMMIT}" "${S}/subprojects/dxil-spirv" || die
	fi
}

src_prepare() {
	default

	sed -i -e "s/@@VCS_COMMIT@@/${VKD3D_COMMIT}/g" meson.build

	rm -rf "subprojects/Vulkan-Headers" || die
	mkdir -p "subprojects/Vulkan-Headers/include" || die
	ln -s "/usr/include/vulkan" "subprojects/Vulkan-Headers/include/vulkan" || die

	rm -rf "subprojects/SPIRV-Headers" || die
	mkdir -p "subprojects/SPIRV-Headers/include" || die
	ln -s "/usr/include/spirv" "subprojects/SPIRV-Headers/include/spirv" || die

	rm -rf "subprojects/dxil-spirv/third_party/spirv-headers" || die
	mkdir -p "subprojects/dxil-spirv/third_party/spirv-headers/include" || die
	ln -s "/usr/include/spirv" "subprojects/dxil-spirv/third_party/spirv-headers/include/spirv" || die

	# Create versioned setup script
	cp "setup_vkd3d_proton.sh" "${PN}-setup"
	sed -e "s#basedir=.*#basedir=\"${EPREFIX}/usr\"#" -i "${PN}-setup" || die

	# Change mention of x86 to x32 in setup script
	# same thing for our purpose, but won't break next sed
	sed -e "s#x86#x32#" -i "${PN}-setup" || die

	bootstrap_vkd3d-proton() {
		# Set vkd3d-proton location for each ABI
		sed -e "s#x$(bits)#$(get_libdir)/${PN}#" -i "${S}/${PN}-setup" || die

		# Add *FLAGS to cross-file
		sed -i \
			-e "s!@CFLAGS@!$(_meson_env_array "${CFLAGS}")!" \
			-e "s!@CXXFLAGS@!$(_meson_env_array "${CXXFLAGS}")!" \
			-e "s!@LDFLAGS@!$(_meson_env_array "${LDFLAGS}")!" \
			build-win$(bits).txt || die
	}

	multilib_foreach_abi bootstrap_vkd3d-proton

	# Clean missed ABI in setup script
	sed -e "s#.*x32.*##" -e "s#.*x64.*##" \
		-i "${PN}-setup" || die
}

multilib_src_configure() {
	# If we use portage's strip FEATURE it will
	# try to use the native strip program, so let meson
	# do the stripping.
	local emesonargs=(
		--cross-file="${S}/build-win$(bits).txt"
		--libdir="$(get_libdir)/${PN}"
		--bindir="$(get_libdir)/${PN}"
		--strip
		-Denable_tests=false
	)

	meson_src_configure
}

multilib_src_compile() {
	meson_src_compile
}

multilib_src_install() {
	meson_src_install
}

multilib_src_install_all() {
	# The .a files are needed during the install phase.
	find "${D}" -name '*.a' -delete -print
	find "${D}" -name 'libvkd3d-proton-utils-*' -delete -print

	# Create combined setup helper
	exeinto /usr/bin
	doexe "${S}/${PN}-setup"

	einstalldocs
}

pkg_postinst() {
	elog ""
	elog "vkd3d-proton installed, but not activated. You have to install the DLLs to a WINEPREFIX."
	elog "To do this you just need to set WINEPREFIX: $ export WINEPREFIX=/path/to/prefix"
	elog "then run: $ ${PN}-setup install --symlink"
	elog ""
}
