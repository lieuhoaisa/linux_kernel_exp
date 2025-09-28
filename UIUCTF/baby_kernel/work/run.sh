#! /bin/sh

# Note: -serial mon:stdio is here for convenience purposes.
# Remotely the chal is run with -serial stdio.

musl-gcc ./exploit.c -o exploit -static
mv ./exploit ./initramfs/
cd initramfs
find . -print0 | cpio --null --format=newc -o 2>/dev/null | gzip -9 > ../initrd_updated.cpio.gz
cd ../

qemu-system-x86_64 \
  -no-reboot \
  -cpu max \
  -net none \
  -serial mon:stdio \
  -display none \
  -monitor none \
  -vga none \
  -kernel bzImage \
  -initrd initrd_updated.cpio.gz \
  -append "console=ttyS0" \
  -s