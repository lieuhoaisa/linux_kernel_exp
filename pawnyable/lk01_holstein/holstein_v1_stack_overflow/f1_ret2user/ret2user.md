some prerequisites...

### Kernel modules?

before analyse the Holstein modules, should read this slides of `pwn.college` to understand what is kernel modules: [slides](/pawnyable/lk01_holstein/holstein_v1_stack_overflow/f1_ret2user/assets/Kernel_Security_3_Kernel_Modules.pdf)

then can continue read this to understand vuln and analysis: [blog](https://pawnyable.cafe/linux-kernel/LK01/welcome-to-holstein.html#Holstein%E3%83%A2%E3%82%B8%E3%83%A5%E3%83%BC%E3%83%AB%E3%81%AE%E8%A7%A3%E6%9E%90)

### Classic privilege escalation?

before understand what are `prepare_kernel_cred` and `commit_creds`, should read this slides of `pwn.college`: [slides](/pawnyable/lk01_holstein/holstein_v1_stack_overflow/f1_ret2user/assets/Kernel_Security_4_Privilege_Escalation.pdf)

then, there are two helpful blogs explain details about these: [here](https://github.com/5o1z/kNotes/tree/main/LKE/LK01/V1#prepare_kernel_cred-and-commit_creds) and [here](https://github.com/vilesport/Kernel-exploit/tree/main/Kernel%20Exploit%20Basics/LK01/HTV1#prepare_kernel_cred-and-commit_creds)

or continue with [blog](https://pawnyable.cafe/linux-kernel/LK01/stack_overflow.html#prepare-kernel-cred%E3%81%A8commit-creds)

> deep understanding about these can be helpful...

**Summary**:

Again, just as a reminder, our goal in kernel exploitation is not to pop a shell via `system("/bin/sh")` or `execve("/bin/sh", NULL, NULL)`, but it is to achieve root privileges in the system, then pop a root shell. Typically, the most common way to do this is by using the 2 functions called `commit_creds()` and `prepare_kernel_cred()`, which are functions that already reside in the kernel-space code itself. What we need to do is to call the 2 functions like this:

```C
commit_creds(prepare_kernel_cred(0))
```

> becareful the patched in `Kernel 6.2`...

### Return to userspace?

can this any of these: [this](https://github.com/vilesport/Kernel-exploit/tree/main/Kernel%20Exploit%20Basics/LK01/HTV1#return-to-userspace) or [this](https://github.com/5o1z/kNotes/tree/main/LKE/LK01/V1#return-to-userspace) [this](https://lkmidas.github.io/posts/20210123-linux-kernel-pwn-part-1/#returning-to-userland) or [blog](https://pawnyable.cafe/linux-kernel/LK01/stack_overflow.html#swapgs-%E3%83%A6%E3%83%BC%E3%82%B6%E3%83%BC%E7%A9%BA%E9%96%93%E3%81%B8%E3%81%AE%E5%BE%A9%E5%B8%B0)

> suggest read all in given order...

**Summary**:

Now we have successfully obtained root privileges, but that's not the end of it. The reason is we are still executing in `kernel-mode`. In order to open a root shell, we have to return to `user-mode`. There's no point in gaining root privileges if the process crashes or terminates.

To return to userspace from kernelspace, we have to `swapgs` and `iretq` or `sysretq`,... (`sysretq` is more complicated to get right)

> pls read those link to understand and know what is `save_state`...

### ret2user: no smep, no smap, no kpti, no kaslr

**Summary**:
- Find `prepare_kernel_cred` and `commit_creds` offset via gdb (because there is no mitigations)
- Opening the device
- Save states
- Overwriting return address to escalate privileges function via stack overflow
- Getting root privileges (by `cred`)
- Returning to userland (restore state and return to get shell function)

Tutorial: [blog](https://pawnyable.cafe/linux-kernel/LK01/stack_overflow.html#ret2user-ret2usr)

> exploit code in the same folder