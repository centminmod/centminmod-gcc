```
yum -y install texinfo flex-devel gmp-devel mpfr-devel libmpc-devel bison-devel gcc-gnat
yum -y localinstall /svr-setup/binutils-gcc8-2.29.1-1.el7.x86_64.rpm
yum -y localinstall /svr-setup/gcc8-8.0-1.el7.x86_64.rpm
```

```
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
```

```
/opt/gcc8/bin/gcc -v
Using built-in specs.
COLLECT_GCC=/opt/gcc8/bin/gcc
COLLECT_LTO_WRAPPER=/opt/gcc-8-20180114/libexec/gcc/x86_64-redhat-linux/8.0.0/lto-wrapper
Target: x86_64-redhat-linux
Configured with: ../configure --prefix=/opt/gcc-8-20180114 --disable-multilib --enable-shared --disable-nls --enable-threads=posix --enable-checking=release --with-system-zlib --enable-__cxa_atexit --disable-install-libiberty --disable-libunwind-exceptions --enable-gnu-unique-object --enable-linker-build-id --with-linker-hash-style=gnu --enable-languages=c,c++ --enable-initfini-array --disable-libgcj --enable-gnu-indirect-function --with-tune=generic --build=x86_64-redhat-linux --enable-lto --enable-gold
Thread model: posix
gcc version 8.0.0 20180114 (experimental) (GCC)
```