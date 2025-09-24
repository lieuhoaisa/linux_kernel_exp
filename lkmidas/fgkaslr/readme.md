Its good to know how to bypass `FG-KASLR`...

This two blogs are very details about theory and techniques to bypass it: [here](https://lkmidas.github.io/posts/20210205-linux-kernel-pwn-part-3/) and [here](https://blog.wohin.me/posts/linux-kernel-pwn-01/)

### FG-KASLR

...It’s purpose is to prevent hackers from defeating KASLR in the traditional way, by “rearrange your kernel code at load time on a per-function level granularity, with only around a second added to boot time”...

To bypass FG-KASLR, there are at least two approaches:
- Parts of kernel could not be randomized by FG-KASLR, which are only randomized by KASLR. Only using gadgets and data within these parts is enough for us to complete the exploitation.
- The kernel symbol table `ksymtab` is only randomized by KASLR, so we could utilize ROP to read out addresses of functions randomized by FG-KASLR from `ksymtab`.

> lkmidas's post use 2nd approaches, wohin has both 2 different exploits

**Summary** (follow lkmidas's blog):

1. Run the system multiple times and read `/proc/kallsyms` -> Notice the system uses `FG-KASLR`.
2.  Find the address ranges that aren’t affected by `FG-KASLR` -> Get a few gadgets, `kpti trampoline` and `ksymtab`.
3.  Leak stack cookie and image base from the stack.
4. Stage 1: Leak `commit_creds()` using gadgets from (2) and `ksymtab`, then safely return to userland.
5. Stage 2: Leak `prepare_kernel_cred()` using gadgets from (2) and `ksymtab` (the same as (4)), then safely return to userland.
6. Stage 3: Call `prepare_kernel_cred(0)`, then safely return to userland and save the address of the returned `cred_struct`.
7. Stage 4: Call `commit_creds()` on the saved `cred_struct` from (6) -> open a root shell.

For details, please visit those two blogs, very worth.

**Attention**:

lkmidas's code were hard to control program flow (function call another function), so i made it simpler via **label** in `C` (search `"goto label in C"` on google)...

> Becareful some compiler doesnt support it. If you want to take the address of a label inside a function in C, you have to use `GCC’s labels-as-values` extension — this is not standard C.

After hijacking kernel's saved `rip`  it will ret2user via `user_rip` and continue execute function until it end:

```C
...
void func()
{
	... // do something
    save_state(0);
    user_rip = (u64)(&&label); // dark magic code (thanks chatgpt)

    ... // do something
    rop[inc] = trampoline;
    rop[inc] = 0;
    rop[inc] = 0;
    rop[inc] = user_rip;
    rop[inc] = user_cs;
    rop[inc] = user_rflags;
    rop[inc] = user_rsp;
    rop[inc] = user_ss;

    puts("[*][*] overwriting");
    write(dev_fd, (char *)&rop, idx * 8);

    puts("[!] should never be reached"); // flow should be directly to label

label:
    ... (do something)
}
...
```

its just for easier to control flow program (for debug), also i changed `save_state` to define `marco`. It will help save current function's frame instead of normal `save_state` function...