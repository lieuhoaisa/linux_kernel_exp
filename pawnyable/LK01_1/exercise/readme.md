some question's answers...

### Question 2

```
As seen in the Security Mechanism section, SMEP is controlled by the 21st bit of the CR4 register. Can I disable SMEP by setting the 21st bit of the CR4 register to 0 with kROP and escalate privileges using ret2user? Write exploit if possible, and explain why if not.
```

Actually yes? Read [this](https://github.com/5o1z/kNotes/tree/main/LKE/LK01/HolsteinV1#question-2). However, in the high version kernel, the 20th and 21st bits of CR4 are pinned on boot, and will immediately be set again after being cleared, so they can never be overwritten this way anymore.

Also read [failed attemp to overwrite CR4](https://lkmidas.github.io/posts/20210128-linux-kernel-pwn-part-2/#the-attempt-to-overwrite-cr4) of lkmidas.

### Question 3

```
When SMAP, SMEP, KPTI is disabled and KASLR is enabled, use Stack Overflow vulnerabilities only (i.e., not using read) to escalate privileges.
Tip: Check the register value at the moment you run the shellcode with ret2usr.
```

The `r8` register still contain kernel's address value, use it to calculate kernel base, and padding to our gadget, similar like this:

```C
void escape_privis()
{
       __asm__(
        ".intel_syntax noprefix;"
        "mov rax, r8;"
        "sub rax, 0xea4608;"
        "add [prepare_kernel_cred], rax;"
        "add [commit_creds], rax;"
        "mov rax, prepare_kernel_cred;"
        "xor rdi, rdi;"
        "call rax;"
        ...
```

**Attention**:

When i tried use `[rbp + 8]` values like [this](https://github.com/5o1z/kNotes/tree/main/LKE/LK01/HolsteinV1#question-3) (not using read function), my exploit didn't stable and very weird behaviour, so i swap to use `r8`, should be more becareful..

When solving this, `solz` met another error with compiler, which is interesting and worth to read, [here](https://github.com/5o1z/kNotes/tree/main/LKE/LK01/HolsteinV1#question-3), (keyword `endbr64`)...

> full exploit in the same folder