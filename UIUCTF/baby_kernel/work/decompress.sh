#!/bin/bash

# Decompress a .cpio.gz packed file system
mkdir initramfs
pushd . && pushd initramfs
cp ../initrd.cpio.gz .
gzip -dc initrd.cpio.gz | cpio -idm &>/dev/null && rm initrd.cpio.gz
