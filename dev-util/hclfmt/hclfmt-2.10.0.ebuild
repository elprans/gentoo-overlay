# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit go-module

EGO_SUM=(
	"github.com/agext/levenshtein v1.2.1"
	"github.com/agext/levenshtein v1.2.1/go.mod"
	"github.com/apparentlymart/go-dump v0.0.0-20180507223929-23540a00eaa3"
	"github.com/apparentlymart/go-dump v0.0.0-20180507223929-23540a00eaa3/go.mod"
	"github.com/apparentlymart/go-textseg v1.0.0"
	"github.com/apparentlymart/go-textseg v1.0.0/go.mod"
	"github.com/apparentlymart/go-textseg/v13 v13.0.0"
	"github.com/apparentlymart/go-textseg/v13 v13.0.0/go.mod"
	"github.com/davecgh/go-spew v1.1.1"
	"github.com/davecgh/go-spew v1.1.1/go.mod"
	"github.com/go-test/deep v1.0.3"
	"github.com/go-test/deep v1.0.3/go.mod"
	"github.com/golang/protobuf v1.1.0/go.mod"
	"github.com/golang/protobuf v1.3.1/go.mod"
	"github.com/golang/protobuf v1.3.4"
	"github.com/golang/protobuf v1.3.4/go.mod"
	"github.com/google/go-cmp v0.2.0"
	"github.com/google/go-cmp v0.2.0/go.mod"
	"github.com/google/go-cmp v0.3.1"
	"github.com/google/go-cmp v0.3.1/go.mod"
	"github.com/hashicorp/hcl/v2 v2.0.0"
	"github.com/hashicorp/hcl/v2 v2.0.0/go.mod"
	"github.com/hashicorp/hcl/v2 v2.10.0"
	"github.com/hashicorp/hcl/v2 v2.10.0/go.mod"
	"github.com/kr/pretty v0.1.0"
	"github.com/kr/pretty v0.1.0/go.mod"
	"github.com/kr/pty v1.1.1"
	"github.com/kr/pty v1.1.1/go.mod"
	"github.com/kr/text v0.1.0"
	"github.com/kr/text v0.1.0/go.mod"
	"github.com/kylelemons/godebug v0.0.0-20170820004349-d65d576e9348"
	"github.com/kylelemons/godebug v0.0.0-20170820004349-d65d576e9348/go.mod"
	"github.com/mitchellh/go-wordwrap v0.0.0-20150314170334-ad45545899c7"
	"github.com/mitchellh/go-wordwrap v0.0.0-20150314170334-ad45545899c7/go.mod"
	"github.com/pmezard/go-difflib v1.0.0"
	"github.com/pmezard/go-difflib v1.0.0/go.mod"
	"github.com/sergi/go-diff v1.0.0"
	"github.com/sergi/go-diff v1.0.0/go.mod"
	"github.com/spf13/pflag v1.0.2"
	"github.com/spf13/pflag v1.0.2/go.mod"
	"github.com/stretchr/testify v1.2.2"
	"github.com/stretchr/testify v1.2.2/go.mod"
	"github.com/vmihailenco/msgpack v3.3.3+incompatible"
	"github.com/vmihailenco/msgpack v3.3.3+incompatible/go.mod"
	"github.com/vmihailenco/msgpack/v4 v4.3.12"
	"github.com/vmihailenco/msgpack/v4 v4.3.12/go.mod"
	"github.com/vmihailenco/tagparser v0.1.1"
	"github.com/vmihailenco/tagparser v0.1.1/go.mod"
	"github.com/zclconf/go-cty v1.1.0"
	"github.com/zclconf/go-cty v1.1.0/go.mod"
	"github.com/zclconf/go-cty v1.2.0/go.mod"
	"github.com/zclconf/go-cty v1.8.0"
	"github.com/zclconf/go-cty v1.8.0/go.mod"
	"github.com/zclconf/go-cty-debug v0.0.0-20191215020915-b22d67c1ba0b"
	"github.com/zclconf/go-cty-debug v0.0.0-20191215020915-b22d67c1ba0b/go.mod"
	"golang.org/x/crypto v0.0.0-20190308221718-c2843e01d9a2/go.mod"
	"golang.org/x/crypto v0.0.0-20190426145343-a29dc8fdc734"
	"golang.org/x/crypto v0.0.0-20190426145343-a29dc8fdc734/go.mod"
	"golang.org/x/crypto v0.0.0-20191002192127-34f69633bfdc"
	"golang.org/x/crypto v0.0.0-20191002192127-34f69633bfdc/go.mod"
	"golang.org/x/net v0.0.0-20180811021610-c39426892332/go.mod"
	"golang.org/x/net v0.0.0-20190404232315-eb5bcb51f2a3/go.mod"
	"golang.org/x/net v0.0.0-20190603091049-60506f45cf65/go.mod"
	"golang.org/x/net v0.0.0-20200301022130-244492dfa37a"
	"golang.org/x/net v0.0.0-20200301022130-244492dfa37a/go.mod"
	"golang.org/x/sync v0.0.0-20180314180146-1d60e4601c6f"
	"golang.org/x/sync v0.0.0-20180314180146-1d60e4601c6f/go.mod"
	"golang.org/x/sys v0.0.0-20190215142949-d0b11bdaac8a/go.mod"
	"golang.org/x/sys v0.0.0-20190412213103-97732733099d/go.mod"
	"golang.org/x/sys v0.0.0-20190502175342-a43fa875dd82"
	"golang.org/x/sys v0.0.0-20190502175342-a43fa875dd82/go.mod"
	"golang.org/x/text v0.3.0/go.mod"
	"golang.org/x/text v0.3.2"
	"golang.org/x/text v0.3.2/go.mod"
	"golang.org/x/text v0.3.5"
	"golang.org/x/text v0.3.5/go.mod"
	"golang.org/x/tools v0.0.0-20180917221912-90fa682c2a6e"
	"golang.org/x/tools v0.0.0-20180917221912-90fa682c2a6e/go.mod"
	"google.golang.org/appengine v1.1.0/go.mod"
	"google.golang.org/appengine v1.6.5"
	"google.golang.org/appengine v1.6.5/go.mod"
	"gopkg.in/check.v1 v1.0.0-20180628173108-788fd7840127"
	"gopkg.in/check.v1 v1.0.0-20180628173108-788fd7840127/go.mod"
	)

go-module_set_globals

DESCRIPTION="Formatter for HCL (Hashicorp configuration language)"
HOMEPAGE="https://github.com/hashicorp/hcl"

EGO_PN="github.com/hashicorp/hcl/cmd/${PN}"
SRC_URI="https://github.com/hashicorp/hcl/blob/v${PV}/cmd/${PN}/main.go"
SRC_URI+="${EGO_SUM_SRC_URI}"

LICENSE="Apache-2.0 BSD-4 MIT MPL-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND="
	dev-lang/go
"

src_prepare() {
	cp "${FILESDIR}/go.mod" "${S}/" || die
}

src_compile() {
	GOCACHE="${T}/go-cache" go build -mod=readonly \
		-work -o "bin/${PN}" ./ || die
}

src_install() {
	dobin "bin/${PN}"
}
