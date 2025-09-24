#!/bin/sh
musl-gcc ./exploit.c -o exploit -static
mv ./exploit ./root/
cd root; find . -print0 | cpio -o --format=newc --null --owner=root > ../rootfs_updated.cpio
cd ../

qemu-system-x86_64 \
    -m 64M \
    -nographic \
    -kernel bzImage \
    -append "console=ttyS0 loglevel=3 oops=panic panic=-1 nopti kaslr" \
    -no-reboot \
    -cpu qemu64 \
    -gdb tcp::12345 \
    -smp 1 \
    -monitor /dev/null \
    -initrd rootfs_updated.cpio \
    -net nic,model=virtio \
    -net user
