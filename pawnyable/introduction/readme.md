## Debug kernel with gdb

Readers should install qemu-system according to their environment.

```bash
sudo apt install qemu-system
```

### Disk image

> [readmore](https://pawnyable.cafe/linux-kernel/introduction/introduction.html#qemu%E3%81%AE%E5%88%A9%E7%94%A8)

The exercises on this site use the lightweight `cpio` format, which is common in CTFs. Use the cpio command to extract the files as follows:

```bash
mkdir root 
cd root; cpio -idv < ../rootfs.cpio
```

Once you have added or edited the files, repackage them into a cpio file like this:

```bash
find . -print0 | cpio -o --format=newc --null > ../rootfs_updated.cpio
```

### Obtain root

> [readmore](https://github.com/5o1z/kNotes/tree/main/LKE/Intro#obtaining-root-privileges), [readmore](https://github.com/vilesport/Kernel-exploit/tree/main/Intro)

When the kernel starts, one program name `init` is first executed. This program has different paths depending on the configuration, but in many cases `/init` or `/sbin/init`. So that program will look like this:

```bash
#!/bin/sh
# devtmpfs does not get automounted for initramfs
/bin/mount -t devtmpfs devtmpfs /dev

# use the /dev/console device node from devtmpfs if possible to not
# confuse glibc's ttyname_r().
# This may fail (E.G. booted with console=), and errors from exec will
# terminate the shell, so use a subshell for the test
if (exec 0</dev/console) 2>/dev/null; then
    exec 0</dev/console
    exec 1>/dev/console
    exec 2>/dev/console
fi

exec /sbin/init "$@"
```

There’s nothing particularly important written here, but it runs `/sbin/init`. In minimal environments such as those used in CTFs, it’s common for `/init` to directly install drivers or launch a shell. **In fact, if you write `/bin/sh` before the final exec, you can launch a shell with root privileges at kernel boot. However, in that case, necessary initialization steps like driver installation won't be executed, so we won’t overwrite this file for now**.

From `/sbin/init`, the script `/etc/init.d/rcS` is eventually executed. This script runs all files in `/etc/init.d/` that start with the letter `S`. In among them, there is a file look like this (`S99pawnyable`):

```bash
#!/bin/sh

##
## Setup
##
mdev -s
mount -t proc none /proc
mkdir -p /dev/pts
mount -vt devpts -o gid=4,mode=620 none /dev/pts
chmod 666 /dev/ptmx
stty -opost
# echo 2 > /proc/sys/kernel/kptr_restrict
#echo 1 > /proc/sys/kernel/dmesg_restrict

##
## Install driver
##
insmod /root/vuln.ko
mknod -m 666 /dev/holstein c `grep holstein /proc/devices | awk '{print $1;}'` 0

##
## User shell
##
echo -e "\nBoot took $(cut -d' ' -f1 /proc/uptime) seconds\n"
echo "[ Holstein v1 (LK01) - Pawnyable ]"
setsid cttyhack setuidgid 1337 sh

##
## Cleanup
##
umount /proc
poweroff -d 0 -f
```

The line `setsid cttyhack setuidgid 1337 sh` launches a shell with the user ID `1337`. Set it to root when you debug the exploit:

```bash
setsid cttyhack setuidgid 0 sh
```

However, this is not a good idea when you run the exploit in local, because you won't know your exploit will successfully gain root privileges or not. So just set it back to non-root when you run the exploit.

### Attach to QEMU

> [readmore](https://pawnyable.cafe/linux-kernel/introduction/debugging.html#qemu%E3%81%B8%E3%81%AE%E3%82%A2%E3%82%BF%E3%83%83%E3%83%81), [readmore](https://lkmidas.github.io/posts/20210123-linux-kernel-pwn-part-1/#the-qemu-run-script)

Initially, the given `run.sh` looks like this:

```bash
#!/bin/sh
qemu-system-x86_64 \
    -m 64M \
    -nographic \
    -kernel bzImage \
    -append "console=ttyS0 loglevel=3 oops=panic panic=-1 nopti nokaslr" \
    -no-reboot \
    -cpu qemu64 \
    -smp 1 \
    -monitor /dev/null \
    -initrd rootfs.cpio \
    -net nic,model=virtio \
    -net user
```

By editing and adding the following option, you can listen for gdb on TCP port 12345 on the local host:

```bash
-gdb tcp::12345
```

To attach with gdb, set the target with the command:

```bash
pwndbg> target remote localhost:12345
```

If your gdb does not recognize the architecture of the debug target by default, you can set the architecture as follows. (Usually it will recognize it automatically).

```bash
pwndbg> set arch i386:x86-64:intel
```

### Compiling and transferring `exploit`

> [readmore](https://pawnyable.cafe/linux-kernel/introduction/compile-and-transfer.html)

(update this)