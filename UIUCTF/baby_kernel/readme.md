### UIUCTF 2025: Baby Kernel

obviously UAF, read/write after `free`

can allocate buffer with any size -> choose `0x400` to later use `tty` struct

finish LK01-03 should be enough to solve this challenge

heap spray -> corrupted tty struct -> overwrite modprobe_path

### Warning

tty struct if different from pawnyable series (value is different, offset is different but behaviours are still the same) -> so adapt + figure out by urself

kernel will crash after exploit return from main (maybe because tty struct corrupted) -> better to get root shell before exit exploit

`0xm4hm0ud` has different solution (different struct, ret2spill, abcxyz,...), since i can't understand it yet, i will leave here to recheck later: https://0xm4hm0ud.me/posts/uiuctf-2025#baby-kernel

`decompile.sh` to extract `initramfs` folder, when `run.sh`, exit shell also crash (funni dev), press `ctrl + A -> X` to close qemu...