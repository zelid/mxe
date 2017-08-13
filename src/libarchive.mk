# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := libarchive
$(PKG)_WEBSITE  := https://www.libarchive.org/
$(PKG)_DESCR    := Libarchive
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 3.3.2
$(PKG)_CHECKSUM := ed2dbd6954792b2c054ccf8ec4b330a54b85904a80cef477a1c74643ddafa0ce
$(PKG)_SUBDIR   := $(PKG)-$($(PKG)_VERSION)
$(PKG)_FILE     := $(PKG)-$($(PKG)_VERSION).tar.gz
$(PKG)_URL      := https://www.libarchive.org/downloads/$($(PKG)_FILE)
$(PKG)_DEPS     := gcc bzip2 libiconv libxml2 nettle openssl xz zlib

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://www.libarchive.org/downloads/' | \
    $(SED) -n 's,.*libarchive-\([0-9][^<]*\)\.tar.*,\1,p' | \
    $(SORT) -V | \
    tail -1
endef

define $(PKG)_BUILD
    $(if $(BUILD_STATIC),\
        $(SED) -i '1i#ifndef LIBARCHIVE_STATIC\n#define LIBARCHIVE_STATIC\n#endif' -i '$(1)/libarchive/archive.h'
        $(SED) -i '1i#ifndef LIBARCHIVE_STATIC\n#define LIBARCHIVE_STATIC\n#endif' -i '$(1)/libarchive/archive_entry.h')

    # use nettle instead of bcrypt for CNG(Crypto Next Generation)
    cd '$(1)' && ./configure \
        $(MXE_CONFIGURE_OPTS) \
        --disable-bsdtar \
        --disable-bsdcpio \
        --disable-bsdcat \
        --without-cng \
        --with-nettle \
        XML2_CONFIG='$(PREFIX)/$(TARGET)'/bin/xml2-config
    $(MAKE) -C '$(1)' -j '$(JOBS)' man_MANS=
    $(MAKE) -C '$(1)' -j 1 install man_MANS=

    '$(TARGET)-gcc' \
        -W -Wall -Werror -ansi -pedantic \
        '$(TEST_FILE)' -o '$(PREFIX)/$(TARGET)/bin/test-libarchive.exe' \
        `'$(TARGET)-pkg-config' --libs-only-l libarchive`
endef
