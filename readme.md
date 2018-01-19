Work In Progress
===

* GCC 7.x & 8.x compiler work for [CentminMod.com](https://community.centminmod.com/threads/13726/)
* CentOS 7.x only
* Optional support for Profile Guided Optimization based GCC builds for ~7-10% better performance for resulting binaries built

Build both GCC 7 & GCC 8 RPMs (both PGO + non-PGO) and accompanying Binutils RPMs all at once

```
-rw-r--r--   1 root  root   37M Jan 19 10:01 binutils-gcc7-2.29.1-1.x86_64.rpm
-rw-r--r--   1 root  root   37M Jan 19 10:07 binutils-gcc8-2.29.1-1.x86_64.rpm
-rw-r--r--   1 root  root  123M Jan 19 07:58 gcc7-all-7.2.1-1.x86_64.rpm
-rw-r--r--   1 root  root  133M Jan 19 08:28 gcc7-all-pgo-7.2.1-1.x86_64.rpm
-rw-r--r--   1 root  root  149M Jan 19 08:57 gcc8-all-8.0-1.x86_64.rpm
-rw-r--r--   1 root  root  162M Jan 19 09:38 gcc8-all-pgo-8.0-1.x86_64.rpm
```