GCC 7 & 8 Compiler Scripts
===

* GCC 7.x & 8.x compiler & Binutils build scripts for install and creation of RPMs for [CentminMod.com](https://community.centminmod.com/threads/13726/) LEMP stacks
* GCC 7.x & 8.x snapshots are built from sources at [http://www.netgull.com/gcc/snapshots/LATEST-7/](http://www.netgull.com/gcc/snapshots/LATEST-7/) and [http://www.netgull.com/gcc/snapshots/LATEST-8/](http://www.netgull.com/gcc/snapshots/LATEST-8/) respectively using CentOS SCL devtoolset-7 provided GCC 7.2.1 compiler.
* CentOS 7.x only
* Optional support for Profile Guided Optimization based GCC builds for ~7-10% better performance for resulting binaries built

Command Line Usage for install.sh
===

```
./install.sh

Usage:

./install.sh {install|install7|install8|installpgo7|installpgo8|installgcc|installgcc7|installgcc8|installpgogcc7|installpgogcc8|binutils7|binutils8}
```

Build GCC 8 RPM + Binutils RPM Only and `without` installing. If you want to install the RPM too set in `install.sh` the variable `GCC_YUMINSTALL='y'`

```
./install.sh install8
```

Build GCC 7 RPM + Binutils RPM Only and `without` installing. If you want to install the RPM too set in `install.sh` the variable `GCC_YUMINSTALL='y'`

```
./install.sh install7
```

Build GCC 8 RPM only without Binutils RPM and `without` installing. If you want to install the RPM too set in `install.sh` the variable `GCC_YUMINSTALL='y'`

```
./install.sh installgcc8
```

Build GCC 7 RPM only without Binutils RPM and `without` installing. If you want to install the RPM too set in `install.sh` the variable `GCC_YUMINSTALL='y'`

```
./install.sh installgcc7
```

Build GCC 8 RPM only with PGO enabled without Binutils RPM and `without` installing. If you want to install the RPM too set in `install.sh` the variable `GCC_YUMINSTALL='y'`

```
./install.sh installpgogcc8
```

Build GCC 7 RPM only with PGO enabled without Binutils RPM and `without` installing. If you want to install the RPM too set in `install.sh` the variable `GCC_YUMINSTALL='y'`

```
./install.sh installpgogcc7
```

Build Binutils RPM Only without GCC RPM and `without` installing. If you want to install the RPM too set in `install.sh` the variable `GCC_YUMINSTALL='y'`

```
./install.sh binutils8
```

Build Binutils RPM Only without GCC RPM and `without` installing. If you want to install the RPM too set in `install.sh` the variable `GCC_YUMINSTALL='y'`

```
./install.sh binutils7
```

GCC 7 & 8 Usage
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

```
source /opt/gcc7/enable
```

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

RPMs
===

Build both GCC 7 & GCC 8 RPMs (both PGO + non-PGO) and accompanying Binutils RPMs all at once

```
ls -lah /svr-setup | egrep 'gcc[7,8]-all|binutils-gcc' | grep rpm
-rw-r--r--   1 root  root  5.2M Jan 20 13:24 binutils-gcc7-2.29.1-1.el7.x86_64.rpm
-rw-r--r--   1 root  root  5.2M Jan 20 12:17 binutils-gcc8-2.29.1-1.el7.x86_64.rpm
-rw-r--r--   1 root  root   33M Jan 20 16:41 gcc7-7.2.1-1.el7.x86_64.rpm
-rw-r--r--   1 root  root   37M Jan 20 17:09 gcc7-pgo-7.2.1-1.el7.x86_64.rpm
-rw-r--r--   1 root  root   36M Jan 20 16:09 gcc8-8.0-1.el7.x86_64.rpm
-rw-r--r--   1 root  root   41M Jan 20 17:46 gcc8-pgo-8.0-1.el7.x86_64.rpm
```
