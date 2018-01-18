#!/bin/bash
################################################
# GCC 8 install for Centmin Mod on CentOS
# https://gcc.gnu.org/wiki/InstallingGCC
# https://gcc.gnu.org/wiki/FAQ#configure
# https://gcc.gnu.org/releases.html
# https://gist.github.com/centminmod/f825b26676eab0240d3049d2e7d1c688
# http://wiki.osdev.org/GCC_Cross-Compiler#Binutils
################################################
DT=$(date +"%d%m%y-%H%M%S")
BUILTRPM='y'

# SVN GCC 7 or 8
GCCSVN_VER='8'
GCC_SVN='y'
GCC_VER='7.2.1'
GCC_PREFIX="/opt/gcc-${GCC_VER}"
# download from ftp://gcc.gnu.org/pub/gcc/infrastructure/
# or via wget code for more reliability as
# ./contrib/download_prerequisites script sees to fail to
# download some required packages each time it runs
GCC_DOWNLOADPREREQ='n'
GCC_LTO='y'
GCC_GOLD='y'
# Profile Guided Optimiized GCC build
# using profiledbootstrap
# https://gcc.gnu.org/install/build.html
GCC_PGO='n'
BOOTCFLAGS='n'
BINUTILS_VER='2.29.1'

# GCC Downloads
GMP_FILE='gmp-6.1.0.tar.bz2'
ISL_FILE='isl-0.18.tar.bz2'
MPC_FILE='mpc-1.0.3.tar.gz'
MPFR_FILE='mpfr-3.1.4.tar.bz2'

CLANG_FOUR='n'
OPT_LEVEL=-O2
CCACHE='y'
DIR_TMP='/svr-setup'
CENTMINLOGDIR='/root/centminlogs'
GCC_SNAPSHOTSEVEN='http://www.netgull.com/gcc/snapshots/LATEST-7/'
GCC_SNAPSHOTEIGHT='http://www.netgull.com/gcc/snapshots/LATEST-8/'
GCC_COMPILEOPTS='--enable-bootstrap --enable-plugin --with-gcc-major-version-only --enable-shared --disable-nls --enable-threads=posix --enable-checking=release --with-system-zlib --enable-__cxa_atexit --disable-install-libiberty --disable-libunwind-exceptions --enable-gnu-unique-object --enable-linker-build-id --with-linker-hash-style=gnu --enable-languages=c,c++ --enable-initfini-array --disable-libgcj --enable-gnu-indirect-function --with-tune=generic --build=x86_64-redhat-linux'
################################################
# Setup Colours
black='\E[30;40m'
red='\E[31;40m'
green='\E[32;40m'
yellow='\E[33;40m'
blue='\E[34;40m'
magenta='\E[35;40m'
cyan='\E[36;40m'
white='\E[37;40m'

boldblack='\E[1;30;40m'
boldred='\E[1;31;40m'
boldgreen='\E[1;32;40m'
boldyellow='\E[1;33;40m'
boldblue='\E[1;34;40m'
boldmagenta='\E[1;35;40m'
boldcyan='\E[1;36;40m'
boldwhite='\E[1;37;40m'

Reset="tput sgr0"      #  Reset text attributes to normal
                       #+ without clearing screen.

cecho ()                     # Coloured-echo.
                             # Argument $1 = message
                             # Argument $2 = color
{
message=$1
color=$2
echo -e "$color$message" ; $Reset
return
}

################################################
CENTOSVER=$(awk '{ print $3 }' /etc/redhat-release)

if [[ "$GCC_PGO" = [yY] ]]; then
    PGOTAG='-pgo'
    BOOTCFLAGS='y'
else
    PGOTAG=""
    BOOTCFLAGS='n'
fi

if [[ "$GCC_LTO" = [yY] ]]; then
    LTO_OPT=' --enable-lto'
else
    LTO_OPT=""
fi

if [[ "$GCC_GOLD" = [yY] ]]; then
    GOLD_OPT=' --enable-gold'
else
    GOLD_OPT=""
fi

if [ "$CENTOSVER" == 'release' ]; then
    CENTOSVER=$(awk '{ print $4 }' /etc/redhat-release | cut -d . -f1,2)
    if [[ "$(cat /etc/redhat-release | awk '{ print $4 }' | cut -d . -f1)" = '7' ]]; then
        CENTOS_SEVEN='7'
    fi
fi

if [[ "$(cat /etc/redhat-release | awk '{ print $3 }' | cut -d . -f1)" = '6' ]]; then
    CENTOS_SIX='6'
fi

# Check for Redhat Enterprise Linux 7.x
if [ "$CENTOSVER" == 'Enterprise' ]; then
    CENTOSVER=$(awk '{ print $7 }' /etc/redhat-release)
    if [[ "$(awk '{ print $1,$2 }' /etc/redhat-release)" = 'Red Hat' && "$(awk '{ print $7 }' /etc/redhat-release | cut -d . -f1)" = '7' ]]; then
        CENTOS_SEVEN='7'
        REDHAT_SEVEN='y'
    fi
fi

if [[ -f /etc/system-release && "$(awk '{print $1,$2,$3}' /etc/system-release)" = 'Amazon Linux AMI' ]]; then
    CENTOS_SIX='6'
fi

if [ ! -d "$DIR_TMP" ]; then
    mkdir -p $DIR_TMP
fi

if [ -f /proc/user_beancounters ]; then
    # CPUS='1'
    # MAKETHREADS=" -j$CPUS"
    # speed up make
    CPUS=$(grep -c "processor" /proc/cpuinfo)
    if [[ "$CPUS" -gt '8' ]]; then
        CPUS=$(echo $(($CPUS+2)))
    else
        CPUS=$(echo $(($CPUS+1)))
    fi
    MAKETHREADS=" -j$CPUS"
else
    # speed up make
    CPUS=$(grep -c "processor" /proc/cpuinfo)
    if [[ "$CPUS" -gt '8' ]]; then
        CPUS=$(echo $(($CPUS+4)))
    elif [[ "$CPUS" -eq '8' ]]; then
        CPUS=$(echo $(($CPUS+2)))
    else
        CPUS=$(echo $(($CPUS+1)))
    fi
    MAKETHREADS=" -j$CPUS"
fi

download_prereq() {
    echo
    echo "downloading from ftp://gcc.gnu.org/pub/gcc/infrastructure/"
    rm -rf ${GMP_FILE}
    rm -rf ${ISL_FILE}
    rm -rf ${MPC_FILE}
    rm -rf ${MPFR_FILE}
    wget --no-verbose -O ./${GMP_FILE} ftp://gcc.gnu.org/pub/gcc/infrastructure/${GMP_FILE}
    wget --no-verbose -O ./${ISL_FILE} ftp://gcc.gnu.org/pub/gcc/infrastructure/${ISL_FILE}
    wget --no-verbose -O ./${MPC_FILE} ftp://gcc.gnu.org/pub/gcc/infrastructure/${MPC_FILE}
    wget --no-verbose -O ./${MPFR_FILE} ftp://gcc.gnu.org/pub/gcc/infrastructure/${MPFR_FILE}
    echo
    ls -lah ${GMP_FILE} ${ISL_FILE} ${MPC_FILE} ${MPFR_FILE}
    echo
}

scl_install() {
    if [[ "$(gcc --version | head -n1 | awk '{print $3}' | cut -d . -f1,2 | sed "s|\.|0|")" -gt '407' ]]; then
        echo
        echo "install centos-release-scl for newer gcc and g++ versions"
        if [[ -z "$(rpm -qa | grep rpmforge)" ]]; then
            if [[ "$(rpm -ql centos-release-scl >/dev/null 2>&1; echo $?)" -ne '0' ]]; then
                time yum -y -q install centos-release-scl
            fi
        else
            if [[ "$(rpm -ql centos-release-scl >/dev/null 2>&1; echo $?)" -ne '0' ]]; then
                time yum -y -q install centos-release-scl --disablerepo=rpmforge
            fi
        fi
    fi
    if [[ -z "$(rpm -qa | grep rpmforge)" ]]; then
        if [[ "$(rpm -ql devtoolset-7-gcc >/dev/null 2>&1; echo $?)" -ne '0' ]] || [[ "$(rpm -ql devtoolset-7-gcc-c++ >/dev/null 2>&1; echo $?)" -ne '0' ]] || [[ "$(rpm -ql devtoolset-7-binutils >/dev/null 2>&1; echo  $?)" -ne '0' ]]; then
            time yum -y -q install devtoolset-7-gcc devtoolset-7-gcc-c++ devtoolset-7-binutils
        fi
    else
        if [[ "$(rpm -ql devtoolset-7-gcc >/dev/null 2>&1; echo $?)" -ne '0' ]] || [[ "$(rpm -ql devtoolset-7-gcc-c++ >/dev/null 2>&1; echo $?)" -ne '0' ]] || [[ "$(rpm -ql devtoolset-7-binutils >/dev/null 2>&1; echo  $?)" -ne '0' ]]; then
            time yum -y -q install devtoolset-7-gcc devtoolset-7-gcc-c++ devtoolset-7-binutils --disablerepo=rpmforge
        fi
    fi
    if [[ "$CLANG_FOUR" = [yY] && ! -f /opt/rh/llvm-toolset-7/root/usr/bin/clang ]]; then
        time yum -y install devtoolset-7-runtime llvm-toolset-7-runtime devtoolset-7-libstdc++-devel llvm-toolset-7-clang llvm-toolset-7-llvm-libs llvm-toolset-7-llvm-static llvm-toolset-7-compiler-rt llvm-toolset-7-libomp llvm-toolset-7-clang-libs
    fi
    echo
}

fpm_install() {
    if [[ "$BUILTRPM" = [Yy] ]]; then
        if [ ! -f /usr/local/bin/fpm ]; then
        echo "*************************************************"
        cecho "Install FPM Start..." $boldgreen
        echo "*************************************************"
        echo
        
            fpmpkgs='ruby-devel gcc make rpm-build rubygems'
            for i in ${fpmpkgs[@]}; do 
                echo $i; 
                if [[ "$(rpm --quiet -ql $i; echo $?)" -ne '0' ]]; then
                    yum -y install $i
                fi
            done
            gem install --no-ri --no-rdoc fpm

        echo "*************************************************"
        cecho "Install FPM Completed" $boldgreen
        echo "*************************************************"
        echo
        fi
    fi
}

binutils_install() {

    if [[ -f /opt/rh/devtoolset-7/root/usr/bin/gcc && -f /opt/rh/devtoolset-7/root/usr/bin/g++ ]]; then
        source /opt/rh/devtoolset-7/enable
        # export CFLAGS="${OPT_LEVEL} -pipe -fomit-frame-pointer"
        # export CXXFLAGS="${CFLAGS}"
    else
        scl_install
        source /opt/rh/devtoolset-7/enable
    fi

    if [[ "$GCC_SVN" = [yY] && "$GCCSVN_VER" -eq '7' ]]; then
        GCC_SYMLINK='/opt/gcc7'
        downloadtar_name=$(curl -4s $GCC_SNAPSHOTSEVEN | grep -o '<a .*href=.*>' | sed -e 's/<a /\n<a /g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' | awk -F "/" '/tar.xz/ {print $2}')
        downloadtar_dirname=$(echo "$downloadtar_name" | sed -e 's|.tar.xz||')
        GCC_PREFIX="/opt/${downloadtar_dirname}"
    elif [[ "$GCC_SVN" = [yY] && "$GCCSVN_VER" -eq '8' ]]; then
        GCC_SYMLINK='/opt/gcc8'
        downloadtar_name=$(curl -4s $GCC_SNAPSHOTEIGHT | grep -o '<a .*href=.*>' | sed -e 's/<a /\n<a /g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' | awk -F "/" '/tar.xz/ {print $2}')
        downloadtar_dirname=$(echo "$downloadtar_name" | sed -e 's|.tar.xz||')
        GCC_PREFIX="/opt/${downloadtar_dirname}"
    fi

    cd $DIR_TMP
    if [[ ! -f "binutils-${BINUTILS_VER}.tar.gz" || ! -d "binutils-${BINUTILS_VER}" ]]; then
        wget -cnv "https://ftp.gnu.org/gnu/binutils/binutils-${BINUTILS_VER}.tar.gz"
        tar xvzf "binutils-${BINUTILS_VER}.tar.gz"
    fi
    rm -rf gold.binutils
    mkdir -p gold.binutils
    cd gold.binutils
    ../binutils-${BINUTILS_VER}/configure --prefix="$GCC_PREFIX" --enable-lto --enable-gold --enable-plugins --disable-nls --disable-werror
    time make${MAKETHREADS} all-gold
    time make${MAKETHREADS}
    if [[ "$BUILTRPM" = [Yy] ]]; then
        echo "create GCC RPM package"
        rm -rf /home/fpmtmp/binutils_installdir
        rpm -e binutils-gcc${GCCSVN_VER}
        echo "mkdir -p /home/fpmtmp/binutils_installdir"
        mkdir -p /home/fpmtmp/binutils_installdir
        echo "time make install DESTDIR=/home/fpmtmp/binutils_installdir"
        time make install DESTDIR=/home/fpmtmp/binutils_installdir
        if [ -f /usr/bin/xz ]; then
            FPMCOMPRESS_OPT='--rpm-compression xz'
        else
            FPMCOMPRESS_OPT='--rpm-compression gzip'
        fi

        echo -e "* $(date +"%a %b %d %Y") George Liu <centminmod.com> $BINUTILS_VER\n - Binutils $BINUTILS_VER for centminmod.com LEMP stack installs" > "binutils-gcc${GCCSVN_VER}-changelog"

        echo "fpm -s dir -t rpm -n binutils-gcc${GCCSVN_VER} -v $BINUTILS_VER $FPMCOMPRESS_OPT --rpm-changelog \"binutils-gcc${GCCSVN_VER}-changelog\" --rpm-summary \"Binutils-gcc${GCCSVN_VER} for centminmod.com LEMP stack installs\" -C /home/fpmtmp/binutils_installdir"
        time fpm -s dir -t rpm -n binutils-gcc${GCCSVN_VER} -v $BINUTILS_VER $FPMCOMPRESS_OPT --rpm-changelog "binutils-gcc${GCCSVN_VER}-changelog" --rpm-summary "Binutils-gcc${GCCSVN_VER} for centminmod.com LEMP stack installs" -C /home/fpmtmp/binutils_installdir
        echo
        BINUTIL_RPMPATH="$(pwd)/binutils-gcc${GCCSVN_VER}-${BINUTILS_VER}-1.x86_64.rpm"
        ls -lah "$BINUTIL_RPMPATH"
        echo
        echo "yum -y localinstall binutils-gcc${GCCSVN_VER}-${BINUTILS_VER}-1.x86_64.rpm"
        yum -y localinstall binutils-gcc${GCCSVN_VER}-${BINUTILS_VER}-1.x86_64.rpm
    else
        time make install
    fi
    echo "${GCC_PREFIX}/bin/ld -v"
    ${GCC_PREFIX}/bin/ld -v
    echo "${GCC_PREFIX}/bin/ld.gold -v"
    ${GCC_PREFIX}/bin/ld.gold -v
    echo "${GCC_PREFIX}/bin/ld.bfd -v"
    ${GCC_PREFIX}/bin/ld.bfd -v
}

sourcesetup() {
    echo "*************************************************"
    cecho "Setup ${GCC_PREFIX}/enable" $boldgreen
    echo "*************************************************"
    rm -rf "${GCC_PREFIX}/enable"
cat > "${GCC_PREFIX}/enable" <<EOF
export PATH=${GCC_PREFIX}/bin\${PATH:+:\${PATH}}
export PCP_DIR=${GCC_PREFIX}
rpmlibdir=${GCC_PREFIX}/lib64
# bz1017604: On 64-bit hosts, we should include also the 32-bit library path.
if [ "\$rpmlibdir" != "${GCC_PREFIX}/lib64" ]; then
  rpmlibdir32=":${GCC_PREFIX}/lib"
fi
export LD_LIBRARY_PATH=\$rpmlibdir\$rpmlibdir32\${LD_LIBRARY_PATH:+:\${LD_LIBRARY_PATH}}
EOF
    echo
    echo "*************************************************"
    cecho "Setup ${GCC_PREFIX}/enable completed" $boldgreen
    echo "*************************************************"
    echo
}

install_gcc() {

    if [[ -f /opt/rh/devtoolset-7/root/usr/bin/gcc && -f /opt/rh/devtoolset-7/root/usr/bin/g++ ]]; then
        GCCSEVEN='y'
        source /opt/rh/devtoolset-7/enable
        GCCCFLAGS="'${OPT_LEVEL} -Wno-maybe-uninitialized'"
        # export CXXFLAGS="${CFLAGS}"
        GCC_COMPILEOPTS="${GCC_COMPILEOPTS}${LTO_OPT}${GOLD_OPT}"
    else
        scl_install
        GCCSEVEN='y'
        source /opt/rh/devtoolset-7/enable
        GCCCFLAGS="'${OPT_LEVEL} -Wno-maybe-uninitialized'"
        # export CXXFLAGS="${CFLAGS}"
        GCC_COMPILEOPTS="${GCC_COMPILEOPTS}${LTO_OPT}${GOLD_OPT}"
    fi

    echo "*************************************************"
    cecho "Compile GCC Start..." $boldgreen
    echo "*************************************************"
    echo

    pkgs='texinfo flex-devel gmp-devel mpfr-devel libmpc-devel bison-devel gcc-gnat'
    for i in ${pkgs[@]}; do 
     echo $i; 
     if [[ "$(rpm --quiet -ql $i; echo $?)" -ne '0' ]]; then
        yum -y install $i
     fi
    done

    cd "$DIR_TMP"
    if [[ "$GCC_SVN" = [nN] ]]; then
        rm -rf "gcc-${GCC_VER}*"
        wget http://www.netgull.com/gcc/releases/gcc-${GCC_VER}/gcc-${GCC_VER}.tar.xz
        tar xf gcc-${GCC_VER}.tar.xz
        cd "gcc-${GCC_VER}"
        echo "mkdir -p test"
        mkdir -p test
        cd test
        echo "../gcc-${GCC_VER}/configure --prefix=$GCC_PREFIX --disable-multilib $GCC_COMPILEOPTS"
        ../gcc-${GCC_VER}/configure --prefix="$GCC_PREFIX" --disable-multilib $GCC_COMPILEOPTS
    elif [[ "$GCC_SVN" = [yY] && "$GCCSVN_VER" -eq '7' ]]; then
        GCC_SYMLINK='/opt/gcc7'
        GCCFPM_VER='7.2.1'
        downloadtar_name=$(curl -4s $GCC_SNAPSHOTSEVEN | grep -o '<a .*href=.*>' | sed -e 's/<a /\n<a /g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' | awk -F "/" '/tar.xz/ {print $2}')
        downloadtar_dirname=$(echo "$downloadtar_name" | sed -e 's|.tar.xz||')
        rm -rf "${downloadtar_dirname}"
        rm -rf "${downloadtar_name}"
        echo "wget "$GCC_SNAPSHOTSEVEN/${downloadtar_name}""
        wget "$GCC_SNAPSHOTSEVEN/${downloadtar_name}"
        echo "tar xf ${downloadtar_name}"
        tar xf "${downloadtar_name}"
        cd "$downloadtar_dirname"
        if [[ "$GCC_DOWNLOADPREREQ" = [yY] ]]; then
            ./contrib/download_prerequisites
        else
            download_prereq
        fi
        echo "mkdir -p test"
        mkdir -p test
        cd test
        GCC_PREFIX="/opt/${downloadtar_dirname}"
        if [[ "$CCACHE" != [yY] ]]; then
            export CC="gcc"
            export CXX="g++"
        fi
        echo "../configure --prefix=$GCC_PREFIX --disable-multilib $GCC_COMPILEOPTS"
        ../configure --prefix="$GCC_PREFIX" --disable-multilib $GCC_COMPILEOPTS
    elif [[ "$GCC_SVN" = [yY] && "$GCCSVN_VER" -eq '8' ]]; then
        GCC_SYMLINK='/opt/gcc8'
        GCCFPM_VER='8.0'
        downloadtar_name=$(curl -4s $GCC_SNAPSHOTEIGHT | grep -o '<a .*href=.*>' | sed -e 's/<a /\n<a /g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' | awk -F "/" '/tar.xz/ {print $2}')
        downloadtar_dirname=$(echo "$downloadtar_name" | sed -e 's|.tar.xz||')
        rm -rf "${downloadtar_dirname}"
        rm -rf "${downloadtar_name}"
        echo "wget "$GCC_SNAPSHOTEIGHT/${downloadtar_name}""
        wget "$GCC_SNAPSHOTEIGHT/${downloadtar_name}"
        echo "tar xf ${downloadtar_name}"
        tar xf "${downloadtar_name}"
        cd "$downloadtar_dirname"
        if [[ "$GCC_DOWNLOADPREREQ" = [yY] ]]; then
            ./contrib/download_prerequisites
        else
            download_prereq
        fi
        echo "mkdir -p test"
        mkdir -p test
        cd test
        GCC_PREFIX="/opt/${downloadtar_dirname}"
        if [[ "$CCACHE" != [yY] ]]; then
            export CC="gcc"
            export CXX="g++"
        fi
        echo "../configure --prefix=$GCC_PREFIX --disable-multilib $GCC_COMPILEOPTS"
        ../configure --prefix="$GCC_PREFIX" --disable-multilib $GCC_COMPILEOPTS
    fi
    echo
    if [[ "$GCC_PGO" = [yY] ]]; then
        if [[ "$BOOTCFLAGS" = [yY] && "$GCCSEVEN" = [Yy] ]]; then
            echo "time make ${MAKETHREADS} profiledbootstrap BOOT_CFLAGS=${GCCCFLAGS} CFLAGS_FOR_TARGET=${GCCCFLAGS}"
            time make${MAKETHREADS} profiledbootstrap BOOT_CFLAGS=${GCCCFLAGS} CFLAGS_FOR_TARGET=${GCCCFLAGS}
        else
            echo "time make${MAKETHREADS} profiledbootstrap"
            time make${MAKETHREADS} profiledbootstrap
        fi
    else
        if [[ "$BOOTCFLAGS" = [yY] && "$GCCSEVEN" = [Yy] ]]; then
            echo "time make ${MAKETHREADS} BOOT_CFLAGS=${GCCCFLAGS} CFLAGS_FOR_TARGET=${GCCCFLAGS}"
            time make${MAKETHREADS} BOOT_CFLAGS=${GCCCFLAGS} CFLAGS_FOR_TARGET=${GCCCFLAGS}
        else
            echo "time make${MAKETHREADS}"
            time make${MAKETHREADS}
        fi
    fi
    echo
    if [[ "$BUILTRPM" = [Yy] ]]; then
        echo "create GCC RPM package"
        rm -rf /home/fpmtmp/gcc_installdir
        rpm -e gcc${GCCSVN_VER}-all
        echo "mkdir -p /home/fpmtmp/gcc_installdir"
        mkdir -p /home/fpmtmp/gcc_installdir
        echo "time make install DESTDIR=/home/fpmtmp/gcc_installdir"
        time make install DESTDIR=/home/fpmtmp/gcc_installdir
        # remove conflicting file with binutils
        rm -rf /home/fpmtmp/gcc_installdir${GCC_PREFIX}/share/info/dir
        if [ -f /usr/bin/xz ]; then
            FPMCOMPRESS_OPT='--rpm-compression xz'
        else
            FPMCOMPRESS_OPT='--rpm-compression gzip'
        fi
cat > symlink.sh <<EOF
#!/bin/bash
if [[ -L "$GCC_SYMLINK" ]]; then
  rm -rf "$GCC_SYMLINK" && ln -s "$GCC_PREFIX" "$GCC_SYMLINK"
fi
EOF
        chmod +x symlink.sh
cat > remove_symlink.sh <<EOF
#!/bin/bash
if [[ -L "$GCC_SYMLINK" ]]; then
  rm -rf "$GCC_SYMLINK"
fi
EOF
        chmod +x remove_symlink.sh

echo -e "* $(date +"%a %b %d %Y") George Liu <centminmod.com> ${GCCSVN_VER}\n - GCC ${GCCSVN_VER} for centminmod.com LEMP stack installs" > "gcc${GCCSVN_VER}-changelog"

        echo "fpm -s dir -t rpm -n gcc${GCCSVN_VER}-all -v $GCCFPM_VER $FPMCOMPRESS_OPT --rpm-changelog \"gcc${GCCSVN_VER}-changelog\" --rpm-summary \"gcc${GCCSVN_VER}-all for centminmod.com LEMP stack installs\" --after-install symlink.sh --before-remove remove_symlink.sh -C /home/fpmtmp/gcc_installdir"
        time fpm -s dir -t rpm -n gcc${GCCSVN_VER}-all -v $GCCFPM_VER $FPMCOMPRESS_OPT --rpm-changelog "gcc${GCCSVN_VER}-changelog" --rpm-summary "gcc${GCCSVN_VER}-all for centminmod.com LEMP stack installs" --after-install symlink.sh --before-remove remove_symlink.sh -C /home/fpmtmp/gcc_installdir
        echo
        GCCRPM_PATH="$(pwd)/gcc${GCCSVN_VER}-all-${GCCFPM_VER}-1.x86_64.rpm"
        ls -lah "$GCCRPM_PATH"
        echo
        echo "yum -y localinstall gcc${GCCSVN_VER}-all-${GCCFPM_VER}-1.x86_64.rpm"
        yum -y localinstall gcc${GCCSVN_VER}-all-${GCCFPM_VER}-1.x86_64.rpm
    else
        echo "time make install"
        time make install
    fi
    errcheck=$?
    if [[ "$errcheck" -eq '0' ]]; then
        cd "$GCC_PREFIX"
        rm -rf "$GCC_SYMLINK"
        ln -s "$GCC_PREFIX" "$GCC_SYMLINK"
    fi
    echo

    echo "*************************************************"
    cecho "Setup ${GCC_PREFIX}/enable" $boldgreen
    echo "*************************************************"
    rm -rf "${GCC_PREFIX}/enable"
cat > "${GCC_PREFIX}/enable" <<EOF
export PATH=${GCC_PREFIX}/bin\${PATH:+:\${PATH}}
export PCP_DIR=${GCC_PREFIX}
rpmlibdir=${GCC_PREFIX}/lib64
# bz1017604: On 64-bit hosts, we should include also the 32-bit library path.
if [ "\$rpmlibdir" != "${GCC_PREFIX}/lib64" ]; then
  rpmlibdir32=":${GCC_PREFIX}/lib"
fi
export LD_LIBRARY_PATH=\$rpmlibdir\$rpmlibdir32\${LD_LIBRARY_PATH:+:\${LD_LIBRARY_PATH}}
EOF
    echo
    echo "*************************************************"
    cecho "Setup ${GCC_PREFIX}/enable completed" $boldgreen
    echo "*************************************************"

    echo
    echo "${GCC_PREFIX}/bin/ld -v"
    "${GCC_PREFIX}/bin/ld" -v

    echo
    echo "${GCC_PREFIX}/bin/ld.gold -v"
    "${GCC_PREFIX}/bin/ld.gold" -v

    echo
    echo "${GCC_PREFIX}/bin/ld.bfd -v"
    "${GCC_PREFIX}/bin/ld.bfd" -v

    echo
    echo "${GCC_PREFIX}/bin/gcc --version"
    "${GCC_PREFIX}/bin/gcc" --version

    echo
    echo "${GCC_PREFIX}/bin/g++ --version"
    "${GCC_PREFIX}/bin/g++" --version

    echo
    echo "${GCC_PREFIX}/bin/gcc -v"
    "${GCC_PREFIX}/bin/gcc" -v

    if [[ "$BUILTRPM" = [Yy] ]]; then
        echo
        echo "RPMs Built"
        echo "$BINUTIL_RPMPATH"
        echo "$GCCRPM_PATH"
        echo
        echo "moved to: $DIR_TMP"
        mv "$BINUTIL_RPMPATH" "$DIR_TMP"
        mv "$GCCRPM_PATH" "$DIR_TMP"
        echo "ls -lah $DIR_TMP | egrep 'gcc${GCCSVN_VER}-all-${GCCFPM_VER}-1.x86_64.rpm|binutils-gcc${GCCSVN_VER}-${BINUTILS_VER}-1.x86_64.rpm'"
        ls -lah "$DIR_TMP | egrep 'gcc${GCCSVN_VER}-all-${GCCFPM_VER}-1.x86_64.rpm|binutils-gcc${GCCSVN_VER}-${BINUTILS_VER}-1.x86_64.rpm'"
        echo
        yum -q info "binutils-gcc${GCCSVN_VER}"
        echo
        rpm -qa --changelog "binutils-gcc${GCCSVN_VER}"
        echo
        yum -q info "gcc${GCCSVN_VER}-all"
        echo
        rpm -qa --changelog "gcc${GCCSVN_VER}-all"
        echo
    fi

    echo
    echo "*************************************************"
    cecho "Compile GCC Completed" $boldgreen
    echo "log: ${CENTMINLOGDIR}/tools-gcc-install${PGOTAG}_${DT}.log"
    echo "*************************************************"
}

#########################
case "$1" in
    install )
            starttime=$(TZ=UTC date +%s.%N)
        {
            fpm_install
            binutils_install
            install_gcc
            # postfixsetup
        } 2>&1 | tee "${CENTMINLOGDIR}/tools-gcc-install${PGOTAG}_${DT}.log"
            endtime=$(TZ=UTC date +%s.%N)
            INSTALLTIME=$(echo "scale=2;$endtime - $starttime"|bc )
            echo "" >> "${CENTMINLOGDIR}/tools-gcc-install${PGOTAG}_${DT}.log"
            echo "Total Binutils + GCC Install Time: $INSTALLTIME seconds" >> "${CENTMINLOGDIR}/tools-gcc-install${PGOTAG}_${DT}.log"
            tail -2 "${CENTMINLOGDIR}/tools-gcc-install${PGOTAG}_${DT}.log"
        ;;
    binutils7 )
        GCCSVN_VER='7'
            starttime=$(TZ=UTC date +%s.%N)
        {
            fpm_install
            binutils_install
            # postfixsetup
        } 2>&1 | tee "${CENTMINLOGDIR}/tools-binutils-install${PGOTAG}_${DT}.log"
            endtime=$(TZ=UTC date +%s.%N)
            INSTALLTIME=$(echo "scale=2;$endtime - $starttime"|bc )
            echo "" >> "${CENTMINLOGDIR}/tools-binutils-install${PGOTAG}_${DT}.log"
            echo "Total Binutils + GCC Install Time: $INSTALLTIME seconds" >> "${CENTMINLOGDIR}/tools-binutils-install${PGOTAG}_${DT}.log"
            tail -2 "${CENTMINLOGDIR}/tools-binutils-install${PGOTAG}_${DT}.log"
        ;;
    binutils8 )
        GCCSVN_VER='8'
            starttime=$(TZ=UTC date +%s.%N)
        {
            fpm_install
            binutils_install
            # postfixsetup
        } 2>&1 | tee "${CENTMINLOGDIR}/tools-binutils-install${PGOTAG}_${DT}.log"
            endtime=$(TZ=UTC date +%s.%N)
            INSTALLTIME=$(echo "scale=2;$endtime - $starttime"|bc )
            echo "" >> "${CENTMINLOGDIR}/tools-binutils-install${PGOTAG}_${DT}.log"
            echo "Total Binutils + GCC Install Time: $INSTALLTIME seconds" >> "${CENTMINLOGDIR}/tools-binutils-install${PGOTAG}_${DT}.log"
            tail -2 "${CENTMINLOGDIR}/tools-binutils-install${PGOTAG}_${DT}.log"
        ;;
    install7 )
        GCCSVN_VER='7'
            starttime=$(TZ=UTC date +%s.%N)
        {
            fpm_install
            binutils_install
            install_gcc
            # postfixsetup
        } 2>&1 | tee "${CENTMINLOGDIR}/tools-gcc-install${PGOTAG}_${DT}.log"
            endtime=$(TZ=UTC date +%s.%N)
            INSTALLTIME=$(echo "scale=2;$endtime - $starttime"|bc )
            echo "" >> "${CENTMINLOGDIR}/tools-gcc-install${PGOTAG}_${DT}.log"
            echo "Total Binutils + GCC Install Time: $INSTALLTIME seconds" >> "${CENTMINLOGDIR}/tools-gcc-install${PGOTAG}_${DT}.log"
            tail -2 "${CENTMINLOGDIR}/tools-gcc-install${PGOTAG}_${DT}.log"
        ;;
    install8 )
        GCCSVN_VER='8'
            starttime=$(TZ=UTC date +%s.%N)
        {
            fpm_install
            binutils_install
            install_gcc
            # postfixsetup
        } 2>&1 | tee "${CENTMINLOGDIR}/tools-gcc-install${PGOTAG}_${DT}.log"
            endtime=$(TZ=UTC date +%s.%N)
            INSTALLTIME=$(echo "scale=2;$endtime - $starttime"|bc )
            echo "" >> "${CENTMINLOGDIR}/tools-gcc-install${PGOTAG}_${DT}.log"
            echo "Total Binutils + GCC Install Time: $INSTALLTIME seconds" >> "${CENTMINLOGDIR}/tools-gcc-install${PGOTAG}_${DT}.log"
            tail -2 "${CENTMINLOGDIR}/tools-gcc-install${PGOTAG}_${DT}.log"
        ;;
    installgcc )
            starttime=$(TZ=UTC date +%s.%N)
        {
            fpm_install
            install_gcc
            # postfixsetup
        } 2>&1 | tee "${CENTMINLOGDIR}/tools-gcc-install${PGOTAG}_${DT}.log"
            endtime=$(TZ=UTC date +%s.%N)
            INSTALLTIME=$(echo "scale=2;$endtime - $starttime"|bc )
            echo "" >> "${CENTMINLOGDIR}/tools-gcc-install${PGOTAG}_${DT}.log"
            echo "Total GCC Install Time: $INSTALLTIME seconds" >> "${CENTMINLOGDIR}/tools-gcc-install${PGOTAG}_${DT}.log"
            tail -2 "${CENTMINLOGDIR}/tools-gcc-install${PGOTAG}_${DT}.log"
        ;;
    * )
        echo "Usage:"
        echo "$0 {install|install7|install8|installgcc|binutils7|binutils8}"
        ;;
esac