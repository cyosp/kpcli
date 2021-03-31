#!/bin/bash

PKG_NAME="kpcli"
DEBIAN_VERSIONS="buster bullseye"

set -e

VERSION=$1
echo "Version to build: $VERSION"

PWD_BACKUP=$(pwd)
VERSION_PATTERN="Version"
ARCHITECTURE_PATTERN="Architecture"
ARCHITECTURES=$(grep "$ARCHITECTURE_PATTERN" DEBIAN/control | cut -d ' ' -f 2-)

for architecture in $ARCHITECTURES
do
  for version in $DEBIAN_VERSIONS
  do
    echo "Package for Debian: $version and architecture: $architecture"

    TMP_DIR=$(mktemp -d)
    KPCLI_SOURCES_DIR="$TMP_DIR/$$/$PKG_NAME"
    KPCLI_PACKAGE_DIR="$KPCLI_SOURCES_DIR/$PKG_NAME"
    PACKAGE_BIN_DIR=$KPCLI_PACKAGE_DIR/usr/bin
    PACKAGE_DEBIAN_DIR=$KPCLI_PACKAGE_DIR/DEBIAN
    CONTROL_FILE_PATH=$PACKAGE_DEBIAN_DIR/control
    mkdir -p $PACKAGE_BIN_DIR $PACKAGE_DEBIAN_DIR

    cp kpcli $PACKAGE_BIN_DIR
    cp DEBIAN/* $PACKAGE_DEBIAN_DIR

    PACKAGE_VERSION="$VERSION-0+deb"
    case $version in
      bullseye)
        PACKAGE_VERSION+="11"
      ;;
      buster)
        PACKAGE_VERSION+="10"
      ;;
    esac
    PACKAGE_VERSION+="u0"
    sed -i "s/$VERSION_PATTERN.*/$VERSION_PATTERN: $PACKAGE_VERSION/" $CONTROL_FILE_PATH
    sed -i "s/$ARCHITECTURE_PATTERN.*/$ARCHITECTURE_PATTERN: $architecture/" $CONTROL_FILE_PATH

    cd $KPCLI_SOURCES_DIR
    sudo dpkg-deb --build $PKG_NAME 2>&1 >/dev/null
    cd $PWD_BACKUP

    cp $KPCLI_SOURCES_DIR/$PKG_NAME.deb ${PKG_NAME}_${PACKAGE_VERSION}_${architecture}.deb

    rm -rf $TMP_DIR
  done
done

exit 0
