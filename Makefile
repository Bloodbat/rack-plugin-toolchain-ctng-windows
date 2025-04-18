# Installation path for executables
LOCAL_DIR := $(PWD)/local
# Local programs should have higher path priority than system-installed programs
export PATH := $(LOCAL_DIR)/bin:$(PATH)

# Allow specifying the number of jobs for toolchain build for systems that need it.
# Due to different build systems used in the toolchain build, just `make -j` won't work here.
# Note: Plugin build uses `$(MAKE)` to inherit `-j` argument from command line.
ifdef JOBS
export JOBS := $(JOBS)
# Define number of jobs for crosstool-ng (uses different argument format)
export JOBS_CT_NG := .$(JOBS)
else
# If `JOBS` is not specified, default to max number of jobs.
export JOBS :=
export JOBS_CT_NG :=
endif

WGET := wget -c
UNTAR := tar -x -f
UNZIP := unzip

SHA256 := sha256check() { echo "$$2  $$1" | sha256sum -c; }; sha256check

CROSSTOOL_NG_VERSION := 1.27.0

# Toolchain build

crosstool-ng := $(LOCAL_DIR)/bin/ct-ng
$(crosstool-ng):
	$(WGET) "http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-$(CROSSTOOL_NG_VERSION).tar.bz2"
	$(SHA256) crosstool-ng-$(CROSSTOOL_NG_VERSION).tar.bz2 6307b93a0abdd1b20b85305210094195825ff00a2ed8b650eeab21235088da4b
	$(UNTAR) crosstool-ng-$(CROSSTOOL_NG_VERSION).tar.bz2
	rm crosstool-ng-$(CROSSTOOL_NG_VERSION).tar.bz2
	cd crosstool-ng-$(CROSSTOOL_NG_VERSION) && ./configure --prefix="$(LOCAL_DIR)"
	cd crosstool-ng-$(CROSSTOOL_NG_VERSION) && make -j $(JOBS)
	cd crosstool-ng-$(CROSSTOOL_NG_VERSION) && make install
	rm -rf crosstool-ng-$(CROSSTOOL_NG_VERSION)

toolchain-win := $(LOCAL_DIR)/x86_64-w64-mingw32
toolchain-win: $(toolchain-win)
$(toolchain-win): $(crosstool-ng)
	ct-ng x86_64-w64-mingw32
	# I don't know how to set crosstool-ng variables from the command line
	sed -i 's/CT_MINGW_W64_VERSION=.*/CT_MINGW_W64_VERSION="v10.0.0"/' .config
	CT_PREFIX="$(LOCAL_DIR)" ct-ng build$(JOBS_CT_NG)
	rm -rf .build .config build.log

# Docker helpers

dep-ubuntu:
	sudo apt-get install --no-install-recommends \
		ca-certificates \
		git \
		build-essential \
		autoconf \
		automake \
		bison \
		flex \
		gawk \
		libtool-bin \
		libncurses5-dev \
		unzip \
		zip \
		jq \
		libgl-dev \
		libglu-dev \
		git \
		wget \
		curl \
		cmake \
		nasm \
		xz-utils \
		file \
		python3 \
		libxml2-dev \
		libssl-dev \
		texinfo \
		help2man \
		libz-dev \
		rsync \
		xxd \
		perl \
		coreutils \
		zstd \
		markdown \
		libarchive-tools \
		gettext

.NOTPARALLEL: