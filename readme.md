GCC 7 & 8 Compiler Scripts
===

* GCC 7.x & 8.x compiler & Binutils build scripts for install and creation of RPMs for [CentminMod.com](https://community.centminmod.com/threads/13726/) LEMP stacks
* GCC 7.x & 8.x snapshots are built from sources at [http://www.netgull.com/gcc/snapshots/LATEST-7/](http://www.netgull.com/gcc/snapshots/LATEST-7/) and [http://www.netgull.com/gcc/snapshots/LATEST-8/](http://www.netgull.com/gcc/snapshots/LATEST-8/) respectively using CentOS SCL devtoolset-7 provided GCC 7.2.1 compiler.
* CentOS 7.x only
* Optional support for Profile Guided Optimization based GCC builds for ~7-10% better performance for resulting binaries built
* GCC 8 as at 20180114 snapshot has [added support for new GCC Retpoline patches](https://community.centminmod.com/posts/58340/) to support new options for `-mindirect-branch`, `-mindirect-return` and `-mindirect-branch-register` to address [Spectre variant 2 vulnerabilities](https://community.centminmod.com/threads/linux-kernel-security-updates-for-spectre-meltdown-vulnerabilities.13648/).
* GCC 7.3 which is currently RC build will also add GCC Repoline patches. Once out of RC, will update script to build against GCC 7.3 branch.

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

GCC 8 Usage
===

* `/opt/gcc-8-20180111` is symlinked to `/opt/gcc8` for easier reference as the GCC snapshot date timestamped builds increment
* Using `/opt/gcc8/enable` allows you to set PATH appropriately. Example gcc binary is at `/opt/gcc8/bin/gcc` but with source file enabled, can reference just as `gcc`

```
source /opt/gcc8/enable
```

or directly without symlink alias

```
source /opt/gcc-8-20180111/enable
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

GCC 7 Usage
===

* `/opt/gcc-7-20180111` is symlinked to `/opt/gcc7` for easier reference as the GCC snapshot date timestamped builds increment
* Using `/opt/gcc7/enable` allows you to set PATH appropriately. Example gcc binary is at `/opt/gcc7/bin/gcc` but with source file enabled, can reference just as `gcc`

```
source /opt/gcc7/enable
```

or directly without symlink alias

```
source /opt/gcc-7-20180111/enable
```

```
gcc -v    
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
./install-all.sh
```

resulting RPMs saved in `/svr-setup` directory built on Intel Core i7 4790K

```
ls -lah /svr-setup | egrep 'gcc[7,8]|binutils-gcc' | grep rpm
-rw-r--r--    1 root      root       5.2M Jan 21 03:37 binutils-gcc7-2.29.1-1.el7.x86_64.rpm
-rw-r--r--    1 root      root       5.2M Jan 21 04:28 binutils-gcc8-2.29.1-1.el7.x86_64.rpm
-rw-r--r--    1 root      root        33M Jan 21 04:00 gcc7-7.2.1-1.el7.x86_64.rpm
-rw-r--r--    1 root      root        37M Jan 21 04:27 gcc7-pgo-7.2.1-1.el7.x86_64.rpm
-rw-r--r--    1 root      root        36M Jan 21 04:51 gcc8-8.0-1.el7.x86_64.rpm
-rw-r--r--    1 root      root        40M Jan 21 05:29 gcc8-pgo-8.0-1.el7.x86_64.rpm

Total Run Time: 6771.610319117 seconds
```

```
yum info binutils-gcc8 -q
Installed Packages
Name        : binutils-gcc8
Arch        : x86_64
Version     : 2.29.1
Release     : 1.el7
Size        : 47 M
Repo        : installed
Summary     : binutils-gcc8 for centminmod.com LEMP stack installs
URL         : https://centminmod.com
License     : unknown
Description : binutils-gcc8 for centminmod.com LEMP stacks
```

```
yum info gcc8-pgo -q
Installed Packages
Name        : gcc8-pgo
Arch        : x86_64
Version     : 8.0
Release     : 1.el7
Size        : 308 M
Repo        : installed
Summary     : gcc8-pgo for centminmod.com LEMP stack installs
URL         : https://centminmod.com
License     : unknown
Description : gcc8-pgo for centminmod.com LEMP stacks
```

```
rpm -qp --provides /svr-setup/binutils-gcc8-2.29.1-1.el7.x86_64.rpm 
binutils-gcc8 = 2.29.1-1.el7
binutils-gcc8(x86-64) = 2.29.1-1.el7
```

```
rpm -qp --requires /svr-setup/binutils-gcc8-2.29.1-1.el7.x86_64.rpm         
ld-linux-x86-64.so.2()(64bit)
ld-linux-x86-64.so.2(GLIBC_2.3)(64bit)
libc.so.6()(64bit)
libc.so.6(GLIBC_2.10)(64bit)
libc.so.6(GLIBC_2.11)(64bit)
libc.so.6(GLIBC_2.14)(64bit)
libc.so.6(GLIBC_2.2.5)(64bit)
libc.so.6(GLIBC_2.3)(64bit)
libc.so.6(GLIBC_2.4)(64bit)
libdl.so.2()(64bit)
libdl.so.2(GLIBC_2.2.5)(64bit)
libm.so.6()(64bit)
rpmlib(CompressedFileNames) <= 3.0.4-1
rpmlib(PartialHardlinkSets) <= 4.0.4-1
rpmlib(PayloadFilesHavePrefix) <= 4.0-1
rtld(GNU_HASH)
rpmlib(PayloadIsXz) <= 5.2-1
```

```
rpm -qp --provides "/svr-setup/gcc8-pgo-8.0-1.el7.x86_64.rpm"
gcc8-pgo = 8.0-1.el7
gcc8-pgo(x86-64) = 8.0-1.el7
libasan.so.5()(64bit)
libatomic.so.1()(64bit)
libatomic.so.1(LIBATOMIC_1.0)(64bit)
libatomic.so.1(LIBATOMIC_1.1)(64bit)
libatomic.so.1(LIBATOMIC_1.2)(64bit)
libcc1.so.0()(64bit)
libcc1plugin.so.0()(64bit)
libcp1plugin.so.0()(64bit)
libgomp.so.1()(64bit)
libgomp.so.1(GOACC_2.0)(64bit)
libgomp.so.1(GOACC_2.0.1)(64bit)
libgomp.so.1(GOMP_1.0)(64bit)
libgomp.so.1(GOMP_2.0)(64bit)
libgomp.so.1(GOMP_3.0)(64bit)
libgomp.so.1(GOMP_4.0)(64bit)
libgomp.so.1(GOMP_4.0.1)(64bit)
libgomp.so.1(GOMP_4.5)(64bit)
libgomp.so.1(GOMP_PLUGIN_1.0)(64bit)
libgomp.so.1(GOMP_PLUGIN_1.1)(64bit)
libgomp.so.1(OACC_2.0)(64bit)
libgomp.so.1(OACC_2.0.1)(64bit)
libgomp.so.1(OMP_1.0)(64bit)
libgomp.so.1(OMP_2.0)(64bit)
libgomp.so.1(OMP_3.0)(64bit)
libgomp.so.1(OMP_3.1)(64bit)
libgomp.so.1(OMP_4.0)(64bit)
libgomp.so.1(OMP_4.5)(64bit)
libitm.so.1()(64bit)
libitm.so.1(LIBITM_1.0)(64bit)
libitm.so.1(LIBITM_1.1)(64bit)
liblsan.so.0()(64bit)
liblto_plugin.so.0()(64bit)
libmpx.so.2()(64bit)
libmpx.so.2(LIBMPX_1.0)(64bit)
libmpx.so.2(LIBMPX_2.0)(64bit)
libmpxwrappers.so.2()(64bit)
libmpxwrappers.so.2(LIBMPXWRAPPERS_1.0)(64bit)
libquadmath.so.0()(64bit)
libquadmath.so.0(QUADMATH_1.0)(64bit)
libquadmath.so.0(QUADMATH_1.1)(64bit)
libssp.so.0()(64bit)
libssp.so.0(LIBSSP_1.0)(64bit)
libstdc++.so.6()(64bit)
libstdc++.so.6(CXXABI_1.3)(64bit)
libstdc++.so.6(CXXABI_1.3.1)(64bit)
libstdc++.so.6(CXXABI_1.3.10)(64bit)
libstdc++.so.6(CXXABI_1.3.11)(64bit)
libstdc++.so.6(CXXABI_1.3.2)(64bit)
libstdc++.so.6(CXXABI_1.3.3)(64bit)
libstdc++.so.6(CXXABI_1.3.4)(64bit)
libstdc++.so.6(CXXABI_1.3.5)(64bit)
libstdc++.so.6(CXXABI_1.3.6)(64bit)
libstdc++.so.6(CXXABI_1.3.7)(64bit)
libstdc++.so.6(CXXABI_1.3.8)(64bit)
libstdc++.so.6(CXXABI_1.3.9)(64bit)
libstdc++.so.6(CXXABI_FLOAT128)(64bit)
libstdc++.so.6(CXXABI_TM_1)(64bit)
libstdc++.so.6(GLIBCXX_3.4)(64bit)
libstdc++.so.6(GLIBCXX_3.4.1)(64bit)
libstdc++.so.6(GLIBCXX_3.4.10)(64bit)
libstdc++.so.6(GLIBCXX_3.4.11)(64bit)
libstdc++.so.6(GLIBCXX_3.4.12)(64bit)
libstdc++.so.6(GLIBCXX_3.4.13)(64bit)
libstdc++.so.6(GLIBCXX_3.4.14)(64bit)
libstdc++.so.6(GLIBCXX_3.4.15)(64bit)
libstdc++.so.6(GLIBCXX_3.4.16)(64bit)
libstdc++.so.6(GLIBCXX_3.4.17)(64bit)
libstdc++.so.6(GLIBCXX_3.4.18)(64bit)
libstdc++.so.6(GLIBCXX_3.4.19)(64bit)
libstdc++.so.6(GLIBCXX_3.4.2)(64bit)
libstdc++.so.6(GLIBCXX_3.4.20)(64bit)
libstdc++.so.6(GLIBCXX_3.4.21)(64bit)
libstdc++.so.6(GLIBCXX_3.4.22)(64bit)
libstdc++.so.6(GLIBCXX_3.4.23)(64bit)
libstdc++.so.6(GLIBCXX_3.4.24)(64bit)
libstdc++.so.6(GLIBCXX_3.4.25)(64bit)
libstdc++.so.6(GLIBCXX_3.4.3)(64bit)
libstdc++.so.6(GLIBCXX_3.4.4)(64bit)
libstdc++.so.6(GLIBCXX_3.4.5)(64bit)
libstdc++.so.6(GLIBCXX_3.4.6)(64bit)
libstdc++.so.6(GLIBCXX_3.4.7)(64bit)
libstdc++.so.6(GLIBCXX_3.4.8)(64bit)
libstdc++.so.6(GLIBCXX_3.4.9)(64bit)
libtsan.so.0()(64bit)
libubsan.so.1()(64bit)
```

```
rpm -qp --requires "/svr-setup/gcc8-pgo-8.0-1.el7.x86_64.rpm"
/bin/sh
/bin/sh
/bin/sh
ld-linux-x86-64.so.2()(64bit)
ld-linux-x86-64.so.2(GLIBC_2.2.5)(64bit)
ld-linux-x86-64.so.2(GLIBC_2.3)(64bit)
libasan.so.5()(64bit)
libatomic.so.1()(64bit)
libc.so.6()(64bit)
libc.so.6(GLIBC_2.10)(64bit)
libc.so.6(GLIBC_2.11)(64bit)
libc.so.6(GLIBC_2.14)(64bit)
libc.so.6(GLIBC_2.16)(64bit)
libc.so.6(GLIBC_2.17)(64bit)
libc.so.6(GLIBC_2.2.5)(64bit)
libc.so.6(GLIBC_2.3)(64bit)
libc.so.6(GLIBC_2.3.2)(64bit)
libc.so.6(GLIBC_2.3.3)(64bit)
libc.so.6(GLIBC_2.6)(64bit)
libcc1.so.0()(64bit)
libcc1plugin.so.0()(64bit)
libcp1plugin.so.0()(64bit)
libdl.so.2()(64bit)
libdl.so.2(GLIBC_2.2.5)(64bit)
libgcc_s.so.1()(64bit)
libgcc_s.so.1(GCC_3.0)(64bit)
libgcc_s.so.1(GCC_3.3)(64bit)
libgcc_s.so.1(GCC_4.2.0)(64bit)
libgomp.so.1()(64bit)
libitm.so.1()(64bit)
liblsan.so.0()(64bit)
liblto_plugin.so.0()(64bit)
libm.so.6()(64bit)
libm.so.6(GLIBC_2.2.5)(64bit)
libmpx.so.2()(64bit)
libmpxwrappers.so.2()(64bit)
libpthread.so.0()(64bit)
libpthread.so.0(GLIBC_2.2.5)(64bit)
libpthread.so.0(GLIBC_2.3.3)(64bit)
libpthread.so.0(GLIBC_2.3.4)(64bit)
libquadmath.so.0()(64bit)
librt.so.1()(64bit)
librt.so.1(GLIBC_2.2.5)(64bit)
libssp.so.0()(64bit)
libstdc++.so.6()(64bit)
libstdc++.so.6(CXXABI_1.3)(64bit)
libstdc++.so.6(CXXABI_1.3.8)(64bit)
libstdc++.so.6(CXXABI_1.3.9)(64bit)
libstdc++.so.6(GLIBCXX_3.4)(64bit)
libstdc++.so.6(GLIBCXX_3.4.20)(64bit)
libstdc++.so.6(GLIBCXX_3.4.21)(64bit)
libstdc++.so.6(GLIBCXX_3.4.9)(64bit)
libtsan.so.0()(64bit)
libubsan.so.1()(64bit)
libz.so.1()(64bit)
rpmlib(CompressedFileNames) <= 3.0.4-1
rpmlib(PartialHardlinkSets) <= 4.0.4-1
rpmlib(PayloadFilesHavePrefix) <= 4.0-1
rtld(GNU_HASH)
rpmlib(PayloadIsXz) <= 5.2-1
```