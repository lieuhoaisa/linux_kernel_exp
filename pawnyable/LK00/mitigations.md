### Linux kernel mitigations

> [readmore](https://lkmidas.github.io/posts/20210123-linux-kernel-pwn-part-1/#linux-kernel-mitigation-features), [readmore](https://pawnyable.cafe/linux-kernel/introduction/security.html)

#### Kernel stack cookies (or canaries)

This is exactly the same as stack canaries on userland. It is enabled in the kernel at compile time and cannot be disabled.

#### SMEP (Supervisor Mode Execution Prevention)

This feature marks all the userland pages in the page table as non-executable when the process is in kernel-mode. In the kernel, this is enabled by setting the `20th bit` of Control Register `CR4`. On boot, it can be enabled by adding `+smep` to `-cpu`, and disabled by adding `nosmep` to `-append`.

```bash
-cpu kvm64,+smep
```

You can also check from inside the machine by looking at `/proc/cpuinfo` :

```bash
cat /proc/cpuinfo | grep smep
```

#### SMAP (Supervisor Mode Access Prevention)

Complementing `SMEP`, this feature marks all the userland pages in the page table as non-accessible when the process is in kernel-mode, which means they cannot be read or written as well. In the kernel, this is enabled by setting the `21st bit` of Control Register `CR4`. On boot, it can be enabled by adding `+smap` to `-cpu`, and disabled by adding `nosmap` to `-append`.

```bash
-cpu kvm64,+smap
```

You can also check from inside the machine by looking at `/proc/cpuinfo` :

```bash
cat /proc/cpuinfo | grep smap
```

#### KASLR (Kernel address space layout randomization)

Also like `ASLR` on userland, it randomizes the base address where the kernel is loaded each time the system is booted. It can be enabled/disabled by adding `kaslr` or `nokaslr` under `-append` option.

```
-append "... nokaslr ..."
```

#### FGKASLR (Function Granular KASLR)

In 2020, an even stronger `KASLR` called `FGKASLR` (Function Granular KASLR) emerged. As of 2022, it appears to be disabled by default, but this is a technique that randomizes the address of each function in the Linux kernel. Even if the address of a function in the Linux kernel can be leaked, the base address cannot be determined. However, `FGKASLR` does not randomize data sections, etc., so the base address can be determined if the address of the data can be leaked. Of course, it is not possible to determine the address of a specific function from the base address, but it can be used for special attack vectors that will appear later.

#### KPTI (Kernel Page-Table Isolation)

When this feature is active, the kernel separates user-space and kernel-space page tables entirely, instead of using just one set of page tables that contains both user-space and kernel-space addresses. One set of page tables includes both kernel-space and user-space addresses same as before, but it is only used when the system is running in kernel mode. The second set of page tables for use in user mode contains a copy of user-space and a minimal set of kernel-space addresses. It can be enabled/disabled by adding `kpti=1` or `nopti` under `-append` option.

KPTI can be enabled by kernel boot arguments. If the qemu `-append` option includes `pti=on`, KPTI is enabled, if includes `noptiit` and `pti=off` , it is disabled.

```bash
-append "... pti=on ..."
```

#### KADR (Kernel Address Display Restriction)

In the Linux kernel, function names and address information can be read from the kernel via `/proc/kallsyms`. Also, some device drivers use `printk` functions to output various debug information to logs, and users can view these logs using commands `dmesg`. In this way, Linux has a mechanism to prevent leaks of address information such as kernel space functions, data, and heaps.

This functionality can be changed by the value `/proc/sys/kernel/kptr_restrict`: If `kptr_restrict` is `0`, there are no restrictions on address visibility; if `kptr_restrict` is `1`, `CAP_SYSLOG` addresses are visible to privileged users; if `kptr_restrict` is `2`, kernel addresses are hidden regardless of the user's privilege level.