#!/bin/sh
set -x
set -e

"${SRCROOT}/xcodescripts/create_system_framework.sh" "${DSTROOT}" "${SRCROOT}" "${ACTION}" "${ARCHS}" "${BUILD_VARIANTS}"

