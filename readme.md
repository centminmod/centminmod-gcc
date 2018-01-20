Work In Progress
===

* GCC 7.x & 8.x compiler work for [CentminMod.com](https://community.centminmod.com/threads/13726/)
* CentOS 7.x only
* Optional support for Profile Guided Optimization based GCC builds for ~7-10% better performance for resulting binaries built

Usage
===

```
source /opt/gcc8/enable
```

```
ld -v
GNU ld (GNU Binutils) 2.29.1

ld.gold -v
GNU gold (GNU Binutils 2.29.1) 1.14
```

```
gcc -v
Using built-in specs.
COLLECT_GCC=gcc
COLLECT_LTO_WRAPPER=/opt/gcc-8-20180114/libexec/gcc/x86_64-redhat-linux/8/lto-wrapper
Target: x86_64-redhat-linux
Configured with: ../configure --prefix=/opt/gcc-8-20180114 --disable-multilib --enable-bootstrap --enable-plugin --with-gcc-major-version-only --enable-shared --disable-nls --enable-threads=posix --enable-checking=release --with-system-zlib --enable-__cxa_atexit --disable-install-libiberty --disable-libunwind-exceptions --enable-gnu-unique-object --enable-linker-build-id --with-linker-hash-style=gnu --enable-languages=c,c++ --enable-initfini-array --disable-libgcj --enable-gnu-indirect-function --with-tune=generic --build=x86_64-redhat-linux --enable-lto --enable-gold
Thread model: posix
gcc version 8.0.0 20180114 (experimental) (GCC) 
```

RPMs
===

Build both GCC 7 & GCC 8 RPMs (both PGO + non-PGO) and accompanying Binutils RPMs all at once

```
ls -lah /svr-setup | egrep 'gcc[7,8]-all|binutils-gcc' | grep rpm
-rw-r--r--    1 root      root       5.6M Jan 20 02:11 binutils-gcc7-2.29.1-1.x86_64.rpm
-rw-r--r--    1 root      root       5.6M Jan 20 03:01 binutils-gcc8-2.29.1-1.x86_64.rpm
-rw-r--r--    1 root      root        35M Jan 20 02:32 gcc7-all-7.2.1-1.x86_64.rpm
-rw-r--r--    1 root      root        39M Jan 20 03:00 gcc7-all-pgo-7.2.1-1.x86_64.rpm
-rw-r--r--    1 root      root        39M Jan 20 03:23 gcc8-all-8.0-1.x86_64.rpm
-rw-r--r--    1 root      root        44M Jan 20 04:01 gcc8-all-pgo-8.0-1.x86_64.rpm

Total Run Time: 6732.971081094 seconds
```

GCC 7
===

```
/opt/gcc7/bin/gcc -v    
Using built-in specs.
COLLECT_GCC=/opt/gcc7/bin/gcc
COLLECT_LTO_WRAPPER=/opt/gcc-7-20180111/libexec/gcc/x86_64-redhat-linux/7/lto-wrapper
Target: x86_64-redhat-linux
Configured with: ../configure --prefix=/opt/gcc-7-20180111 --disable-multilib --enable-bootstrap --enable-plugin --with-gcc-major-version-only --enable-shared --disable-nls --enable-threads=posix --enable-checking=release --with-system-zlib --enable-__cxa_atexit --disable-install-libiberty --disable-libunwind-exceptions --enable-gnu-unique-object --enable-linker-build-id --with-linker-hash-style=gnu --enable-languages=c,c++ --enable-initfini-array --disable-libgcj --enable-gnu-indirect-function --with-tune=generic --build=x86_64-redhat-linux --enable-lto --enable-gold
Thread model: posix
gcc version 7.2.1 20180111 (GCC) 
```

```
/opt/gcc7/bin/ld.gold -v
GNU gold (GNU Binutils 2.29.1) 1.14
```

GCC 8
===

```
/opt/gcc8/bin/gcc -v     
Using built-in specs.
COLLECT_GCC=/opt/gcc8/bin/gcc
COLLECT_LTO_WRAPPER=/opt/gcc-8-20180114/libexec/gcc/x86_64-redhat-linux/8/lto-wrapper
Target: x86_64-redhat-linux
Configured with: ../configure --prefix=/opt/gcc-8-20180114 --disable-multilib --enable-bootstrap --enable-plugin --with-gcc-major-version-only --enable-shared --disable-nls --enable-threads=posix --enable-checking=release --with-system-zlib --enable-__cxa_atexit --disable-install-libiberty --disable-libunwind-exceptions --enable-gnu-unique-object --enable-linker-build-id --with-linker-hash-style=gnu --enable-languages=c,c++ --enable-initfini-array --disable-libgcj --enable-gnu-indirect-function --with-tune=generic --build=x86_64-redhat-linux --enable-lto --enable-gold
Thread model: posix
gcc version 8.0.0 20180114 (experimental) (GCC)
```

```
/opt/gcc8/bin/ld.gold -v 
GNU gold (GNU Binutils 2.29.1) 1.14
```
