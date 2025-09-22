#!/bin/sh
musl-gcc ./exploit.c -o exploit -static
mv ./exploit ./root/
cd root; find . -print0 | cpio -o --null --format=newc > ../rootfs_updated.cpio
cd ../

qemu-system-x86_64 \
    -m 256M \
    -kernel ./bzImage \
    -initrd ./rootfs_updated.cpio \
    -append "root=/dev/ram rw console=ttyS0 oops=panic panic=1 kaslr quiet" \
    -cpu kvm64,+smep,+smap \
    -monitor /dev/null \
    -nographic \
    -gdb tcp::1234
# remove -enable-kvm to run in wsl2