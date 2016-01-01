#!/bin/sh
set -x
[[ $ACTION == "installhdrs" ]] && exit 0

mkdir -p $OBJROOT/UninstalledProducts

$SRCROOT/xcodescripts/compile-syscalls.pl \
	$OBJROOT/sys/stubs.list \
	$BUILD_ROOT/syscalls.a
