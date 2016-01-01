#!/bin/sh
set -x
set -e

"${SRCROOT}/xcodescripts/create_dylib_symlinks.sh" "${DSTROOT}" "${ACTION}" "${BUILD_VARIANTS}"

