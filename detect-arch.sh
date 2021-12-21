#!/bin/sh

MAJOR_VERSION="$SELENIUM_VERSION"
LEGACY_VERSION=3.141.0

if [ "$(uname --m)" = "x86_64" ]; then
    if [ "$(getconf LONG_BIT)" = 64 ]; then
        VERSION="$MAJOR_VERSION"
    else
        VERSION="$LEGACY_VERSION"
    fi
elif [ "$(uname --m)" = "aarch64" ]; then
    VERSION="$MAJOR_VERSION"
else
    VERSION="$LEGACY_VERSION"
fi

echo "$VERSION"

