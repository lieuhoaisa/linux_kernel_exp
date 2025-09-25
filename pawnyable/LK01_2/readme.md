### Ref

there is this post write everything very very details and worth to read: https://blog.wohin.me/posts/pawnyable-0202/

since i learn things based on that post so i wont write any knowledge note here (its also a good reference to review later)

vilex and solz github are also nice to refer (find it by urself)

### Warning

but in here i will note some errors/warning i met during exploiting (maybe bad coding pratice), so i wont make same mistake later (this maybe contain all the UAF chapter or even kernel exploitation, i will keep updating this to be a cheatsheet):

When using heap overflow or uaf to overwrite structure in heap region, remember to rewrite/restore their metadata value (first encounter this bug when declare buffer in 2 different function with 2 different size -> buffer offset is misaligned -> data in buffer misaligned -> overwrite wrong offset -> tty metadata misalign -> trigger error)

My heap overflow exploit scripts (in hof folder) have out of bound bugs at `spray[]` array *=)))))* (my bad my bad) (but its doesnt affect the exploit success (you can know why)), so becareful when reuse the exploit

When heap spraying, if you open any modules or file, remember to close it (i add a cleanup function in uaf exploiting) (first encounter in UAF chapter, i heap spraying then leak then exit without close any fds, the program keep hanging and cant interactive with the shell anymore (imagine like it encounter endless loop). After testing, i know that close fd will solved problems but still dont know reasons yet, so its a good pratice to close any fd before terminating)

My `saved_state` function is not stable as i thought (even i write it to be a macro) (imagine when saved state at function 1 but will trigger hijack at function 2, we easily relize that stack frame will be corrupted) (i think write all the exploit in 1 function will be more stable)

When debuging exploit, add a `getchar()` in a middle of exploit as a breakpoint then using gdb remote into host (its really help)