very strong technique (can even bypass FG-KASLR).

once again, lkmida write very details about this [here](https://lkmidas.github.io/posts/20210223-linux-kernel-pwn-modprobe/)

### modprobe_path

...In short, whatever file whose path is currently stored in `modprobe_path` will be executed when we issue the system to execute a file with an unknown file type. Therefore, the plan of this technique is to use an arbitrary write primitive to overwrite `modprobe_path` into a path to a shell script that we have written ourselves, then we execute a dummy file with an unknown file signature. The result is that the shell script will be executed when the system is still in kernel mode, leading to an **arbitrary code execution with root privileges**...

> For more details and understanding, please read lkmidas's blog

**Summary** (follow lkmidas's blog):

1. Run the system multiple times and read `/proc/kallsyms` -> Notice the system uses `FG-KASLR`.
2.  Find the address ranges that aren’t affected by `FG-KASLR` -> Get a few gadgets, `kpti trampoline` and `modprobe_path`.
3.  Leak stack cookie and image base from the stack.
4. Perform ROPchain that overwrite `modprobe_path` to `"/tmp/x"`.
5. Write some evil shell script that will help gain root into `/tmp/x`
6. Create a dummy file with unknown file signature and execute it to trigger `modprobe_path` (which is now `/tmp/x` an evil script)

**Atention**:

I try to write an exploit that give shell rather than cat flag (its harder than i thougth, need to write 2 different C program (can merge to one but too lazy, TODO...))

Ideas inspire from [here](https://blog.wohin.me/posts/linux-kernel-pwn-01/) (`Case 3.3 Bypass KPTI with User Mode Helpers`)...

> Also good blogs, please read

> Full exploit in same folder