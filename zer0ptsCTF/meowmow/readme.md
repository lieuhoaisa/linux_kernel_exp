### zer0pts CTF 2020: meowmow

reading/writing to the device will verify that the offset is strictly in bound of `0x400` and the size request also in range `0x400`

calling `lseek` on the device can set current file offset

-> it's possible to read and write up to `0x3ff` bytes after the buffer by setting the offset to `0x3ff` and reading or writing with a size of `0x400`

-> heap overflow

bypass `smap`, `smep`, `kaslr`, `kpti`, `kadr`

heap spray -> leak base address -> overwrite `tty_struct` -> pivot rop call `commit_creds(prepare_kernel_cred(0))`