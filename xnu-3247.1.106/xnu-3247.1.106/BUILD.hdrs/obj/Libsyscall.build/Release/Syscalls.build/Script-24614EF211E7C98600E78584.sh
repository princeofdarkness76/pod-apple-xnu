#!/bin/sh
set -x
[[ $ACTION == "installhdrs" ]] && exit 0

mkdir -p $OBJROOT/sys

$SRCROOT/xcodescripts/create-syscalls.pl \
	$SRCROOT/../bsd/kern/syscalls.master \
	$SRCROOT/custom \
	$SRCROOT/Platforms \
	$MAP_PLATFORM \
	$OBJROOT/sys

