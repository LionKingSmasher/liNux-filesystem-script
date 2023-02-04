#!/bin/bash

echo "==================================="
echo "          liNux-fs-gen             "
echo "==================================="
echo ""

NET_OS=$(pwd)/liNux

set +h
umask 022

echo "Create Toolchain Directory..."
install -dv ${NET_OS}/toolchain{,/bin}

unset CFLAGS
unset CXXFLAGS

NET_OS_HOST=$(echo ${MACHTYPE} | sed "s/-[^-]*/-cross/")
NET_OS_TARGET=x86_64-unknown-linux-gnu
NET_OS_CPU=k8
NET_OS_ARCH=$(echo ${NET_OS_TARGET} | sed -e 's/-.*//' -e 's/i.86/i386/')
NET_OS_ENDIAN=little

NET_OS_KERNEL_DIR=$(pwd)/kernel

cd ${NET_OS_KERNEL_DIR} && make mrproper
make ARCH=${NET_OS_ARCH} INSTALL_HDR_PATH=dest headers_install
cp -rv dest/include/* ${NET_OS}/usr/include