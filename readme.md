Work In Progress
===

* GCC 7.x & 8.x compiler work for [CentminMod.com](https://community.centminmod.com/threads/13726/)

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

Binutils Gold Linker for GCC 7

```
/opt/gcc7/bin/ld.gold -v
GNU gold (GNU Binutils 2.29.1) 1.14
```

```
*************************************************
Setup /opt/gcc-7-20180111/enable completed
*************************************************

/opt/gcc-7-20180111/bin/ld -v
GNU ld (GNU Binutils) 2.29.1

/opt/gcc-7-20180111/bin/ld.gold -v
GNU gold (GNU Binutils 2.29.1) 1.14

/opt/gcc-7-20180111/bin/ld.bfd -v
GNU ld (GNU Binutils) 2.29.1

/opt/gcc-7-20180111/bin/gcc --version
gcc (GCC) 7.2.1 20180111
Copyright (C) 2017 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.


/opt/gcc-7-20180111/bin/g++ --version
g++ (GCC) 7.2.1 20180111
Copyright (C) 2017 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.


RPMs Built
/svr-setup/gold.binutils/binutils-gcc7-2.29.1-1.x86_64.rpm
/svr-setup/gcc-7-20180111/test/gcc7-all-7.2.1-1.x86_64.rpm

*************************************************
Compile GCC Completed
log: /root/centminlogs/tools-gcc-install_180118-014408.log
*************************************************

Total Binutils + GCC Install Time: 1450.347774651 seconds
```

GCC 8
===

```
/opt/gcc-8-20180114/bin/gcc -v
Using built-in specs.
COLLECT_GCC=/opt/gcc-8-20180114/bin/gcc
COLLECT_LTO_WRAPPER=/opt/gcc-8-20180114/libexec/gcc/x86_64-redhat-linux/8/lto-wrapper
Target: x86_64-redhat-linux
Configured with: ../configure --prefix=/opt/gcc-8-20180114 --disable-multilib --enable-bootstrap --enable-plugin --with-gcc-major-version-only --enable-shared --disable-nls --enable-threads=posix --enable-checking=release --with-system-zlib --enable-__cxa_atexit --disable-install-libiberty --disable-libunwind-exceptions --enable-gnu-unique-object --enable-linker-build-id --with-linker-hash-style=gnu --enable-languages=c,c++ --enable-initfini-array --disable-libgcj --enable-gnu-indirect-function --with-tune=generic --build=x86_64-redhat-linux --enable-lto --enable-gold
Thread model: posix
gcc version 8.0.0 20180114 (experimental) (GCC)
```

Binutils Gold Linker for GCC 8

```
/opt/gcc8/bin/ld.gold -v
GNU gold (GNU Binutils 2.29.1) 1.14
```

```
*************************************************
Setup /opt/gcc-8-20180114/enable completed
*************************************************

/opt/gcc-8-20180114/bin/ld -v
GNU ld (GNU Binutils) 2.29.1

/opt/gcc-8-20180114/bin/ld.gold -v
GNU gold (GNU Binutils 2.29.1) 1.14

/opt/gcc-8-20180114/bin/ld.bfd -v
GNU ld (GNU Binutils) 2.29.1

/opt/gcc-8-20180114/bin/gcc --version
gcc (GCC) 8.0.0 20180114 (experimental)
Copyright (C) 2018 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.


/opt/gcc-8-20180114/bin/g++ --version
g++ (GCC) 8.0.0 20180114 (experimental)
Copyright (C) 2018 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.


RPMs Built
/svr-setup/gold.binutils/binutils-gcc8-2.29.1-1.x86_64.rpm
/svr-setup/gcc-8-20180114/test/gcc8-all-8.0-1.x86_64.rpm

*************************************************
Compile GCC Completed
log: /root/centminlogs/tools-gcc-install_180118-014537.log
*************************************************

Total Binutils + GCC Install Time: 1651.693089986 seconds
```