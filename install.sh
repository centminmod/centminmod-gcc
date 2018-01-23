#!/bin/bash
################################################
# GCC 8 install for Centmin Mod on CentOS
# https://gcc.gnu.org/wiki/InstallingGCC
# https://gcc.gnu.org/wiki/FAQ#configure
# https://gcc.gnu.org/releases.html
# https://gist.github.com/centminmod/f825b26676eab0240d3049d2e7d1c688
# http://wiki.osdev.org/GCC_Cross-Compiler#Binutils
################################################
VER='0.3'
DT=$(date +"%d%m%y-%H%M%S")
DIR_TMP='/svr-setup'

# RPM related
BUILTRPM='y'
DISTTAG='el7'
RPMSAVE_PATH="$DIR_TMP"
# whether to test install the RPMs build
# or just build RPMs without installing
GCC_YUMINSTALL='n'

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
BOOTCFLAGS='y'
BINUTILS_VER='2.29.1'

# GCC Downloads
GMP_FILE='gmp-6.1.0.tar.bz2'
ISL_FILE='isl-0.18.tar.bz2'
MPC_FILE='mpc-1.0.3.tar.gz'
MPFR_FILE='mpfr-3.1.4.tar.bz2'

CLANG_FOUR='n'
OPT_LEVEL=-O2
CCACHE='y'
CENTMINLOGDIR='/root/centminlogs'
GCC_SNAPSHOTSEVEN='http://www.netgull.com/gcc/snapshots/LATEST-7/'
GCC_SNAPSHOTEIGHT='http://www.netgull.com/gcc/snapshots/LATEST-8/'
GCC_COMPILEOPTS='--enable-bootstrap --enable-plugin --with-gcc-major-version-only --enable-shared --disable-nls --enable-threads=posix --enable-checking=release --with-system-zlib --enable-__cxa_atexit --disable-install-libiberty --disable-libunwind-exceptions --enable-gnu-unique-object --enable-linker-build-id --with-linker-hash-style=gnu --enable-languages=c,c++ --enable-initfini-array --disable-libgcj --enable-gnu-indirect-function --with-tune=generic --build=x86_64-redhat-linux'
SCRIPT_DIR=$(readlink -f $(dirname ${BASH_SOURCE[0]}))
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
        CPUS=$(echo $(($CPUS+1)))
    else
        CPUS=$(echo $(($CPUS+1)))
    fi
    MAKETHREADS=" -j$CPUS"
fi

die() {
    echo "error: $@" >&2
    exit 1
}

tidyup() {
    # logs older than 5 days will be gzip compressed to save space 
    if [ -d /root/centminlogs ]; then
        # find /root/centminlogs -type f -mtime +3 \( -name 'tools-binutils-install_*.log"' -o -name 'tools-gcc-install*.log' \) -exec ls -lah {} \;
        find /root/centminlogs -type f -mtime +3 \( -name 'tools-binutils-install_*.log"' -o -name 'tools-gcc-install*.log' \) -exec gzip -9 {} \;
    fi
}

download_prereq() {
    echo
    echo "downloading from https://github.com/centminmod/gcc-infrastructure/raw/master/"
    rm -rf ${GMP_FILE}
    rm -rf ${ISL_FILE}
    rm -rf ${MPC_FILE}
    rm -rf ${MPFR_FILE}
    wget --no-verbose -O ./${GMP_FILE} https://github.com/centminmod/gcc-infrastructure/raw/master/${GMP_FILE}
    wget --no-verbose -O ./${ISL_FILE} https://github.com/centminmod/gcc-infrastructure/raw/master/${ISL_FILE}
    wget --no-verbose -O ./${MPC_FILE} https://github.com/centminmod/gcc-infrastructure/raw/master/${MPC_FILE}
    wget --no-verbose -O ./${MPFR_FILE} https://github.com/centminmod/gcc-infrastructure/raw/master/${MPFR_FILE}
    echo
    ls -lah ${GMP_FILE} ${ISL_FILE} ${MPC_FILE} ${MPFR_FILE}
    echo
    echo "creating symlinks for gmp, isl, mpc, mpf"
    directory=$(pwd)
    echo "directory=$directory"
    echo_archives="${GMP_FILE} ${ISL_FILE} ${MPC_FILE} ${MPFR_FILE}"
    for ar in ${echo_archives[@]}; do
        package="${ar%.tar*}"
        echo "extracting $package ..."
        if [[ ! -d "$package" ]]; then
            ( cd "${directory}" && tar -xf "${ar}" ) || die "Cannot extract package from ${ar}"
        fi
    done
    unset ar
    for ar in ${echo_archives[@]}; do
        target="${directory}/${ar%.tar*}/"
        linkname="${ar%-*}"
        echo "$linkname"
        rm -f "${linkname}"
        [ -e "${linkname}" ]                                                      \
            || ln -s "${target}" "${linkname}"                                    \
            || die "Cannot create symbolic link ${linkname} --> ${target}"
        unset target linkname
    done
    unset ar
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
        # export CFLAGS="${OPT_LEVEL} -Wimplicit-fallthrough=0"
        # export CXXFLAGS="${CFLAGS}"
    else
        scl_install
        # export CFLAGS="${OPT_LEVEL} -Wimplicit-fallthrough=0"
        # export CXXFLAGS="${CFLAGS}"
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
    rm -rf gold.binutils${GCCSVN_VER}
    mkdir -p gold.binutils${GCCSVN_VER}
    echo "cd ${DIR_TMP}/gold.binutils${GCCSVN_VER}" | tee "${SCRIPT_DIR}/binutils-gcc${GCCSVN_VER}-fpm-cmd"
    cd gold.binutils${GCCSVN_VER}
    ../binutils-${BINUTILS_VER}/configure --prefix="$GCC_PREFIX" --enable-lto --enable-gold --enable-plugins --disable-nls --disable-werror
    time make${MAKETHREADS} all-gold
    time make${MAKETHREADS}
    if [[ "$BUILTRPM" = [Yy] ]]; then
        echo "create GCC RPM package"
        BINUTIL_RPMINSTALLDIR="/home/fpmtmp/binutils${GCCSVN_VER}_installdir"
        rm -rf $BINUTIL_RPMINSTALLDIR
        rpm -e binutils-gcc${GCCSVN_VER}
        echo "mkdir -p $BINUTIL_RPMINSTALLDIR"
        mkdir -p $BINUTIL_RPMINSTALLDIR
        echo "time make install DESTDIR=$BINUTIL_RPMINSTALLDIR"
        time make install DESTDIR=$BINUTIL_RPMINSTALLDIR
        # remove conflicting file with gcc
        if [ -f "rm -rf $BINUTIL_RPMINSTALLDIR${GCC_PREFIX}/share/info/dir" ]; then
            echo "rm -rf $BINUTIL_RPMINSTALLDIR${GCC_PREFIX}/share/info/dir"
            rm -rf "$BINUTIL_RPMINSTALLDIR${GCC_PREFIX}/share/info/dir"
        fi
        if [ -f /usr/bin/xz ]; then
            FPMCOMPRESS_OPT='--rpm-compression xz'
        else
            FPMCOMPRESS_OPT='--rpm-compression gzip'
        fi

        # strip binaries
        binbin_list='ar as ld ld.gold ld.bfd nm objcopy objdump ranlib readelf strip'
        for b in ${binbin_list[@]}; do
            if [ -f "$BINUTIL_RPMINSTALLDIR${GCC_PREFIX}/x86_64-pc-linux-gnu/bin/$b" ]; then
                echo
                echo "ls -lah "$BINUTIL_RPMINSTALLDIR${GCC_PREFIX}/x86_64-pc-linux-gnu/bin/$b""
                ls -lah "$BINUTIL_RPMINSTALLDIR${GCC_PREFIX}/x86_64-pc-linux-gnu/bin/$b"
                echo
                echo "strip "$BINUTIL_RPMINSTALLDIR${GCC_PREFIX}/x86_64-pc-linux-gnu/bin/$b""
                strip "$BINUTIL_RPMINSTALLDIR${GCC_PREFIX}/x86_64-pc-linux-gnu/bin/$b"
                echo
                echo "ls -lah "$BINUTIL_RPMINSTALLDIR${GCC_PREFIX}/x86_64-pc-linux-gnu/bin/$b""
                ls -lah "$BINUTIL_RPMINSTALLDIR${GCC_PREFIX}/x86_64-pc-linux-gnu/bin/$b"
                echo
            fi
        done

        binbinb_list='addr2line dwp size strings gprof c++filt elfedit'
        for bb in ${binbinb_list[@]}; do
            echo
            echo "ls -lah "$BINUTIL_RPMINSTALLDIR${GCC_PREFIX}/bin/$bb""
            ls -lah "$BINUTIL_RPMINSTALLDIR${GCC_PREFIX}/bin/$bb"
            echo
            echo "strip "$BINUTIL_RPMINSTALLDIR${GCC_PREFIX}/bin/$bb""
            strip "$BINUTIL_RPMINSTALLDIR${GCC_PREFIX}/bin/$bb"
            echo
            echo "ls -lah "$BINUTIL_RPMINSTALLDIR${GCC_PREFIX}/bin/$bb""
            ls -lah "$BINUTIL_RPMINSTALLDIR${GCC_PREFIX}/bin/$bb"
            echo
        done

        # remove files
        if [ -d "$BINUTIL_RPMINSTALLDIR${GCC_PREFIX}/x86_64-pc-linux-gnu" ]; then
            rm -rf "$BINUTIL_RPMINSTALLDIR${GCC_PREFIX}/x86_64-pc-linux-gnu"
        fi

        echo -e "* $(date +"%a %b %d %Y") George Liu <centminmod.com> $BINUTILS_VER\n - Binutils $BINUTILS_VER for centminmod.com LEMP stack installs" > "binutils-gcc${GCCSVN_VER}-changelog"

        echo "fpm -f -s dir -t rpm -n binutils-gcc${GCCSVN_VER} -v $BINUTILS_VER $FPMCOMPRESS_OPT --rpm-changelog \"binutils-gcc${GCCSVN_VER}-changelog\" --rpm-summary \"binutils-gcc${GCCSVN_VER} for centminmod.com LEMP stack installs\" --rpm-dist ${DISTTAG}  -m \"<centminmod.com>\" --description \"binutils-gcc${GCCSVN_VER} for centminmod.com LEMP stacks\" --url https://centminmod.com --rpm-autoreqprov -p $DIR_TMP -C $BINUTIL_RPMINSTALLDIR" | tee -a "${SCRIPT_DIR}/binutils-gcc${GCCSVN_VER}-fpm-cmd"
        time fpm -f -s dir -t rpm -n binutils-gcc${GCCSVN_VER} -v $BINUTILS_VER $FPMCOMPRESS_OPT --rpm-changelog "binutils-gcc${GCCSVN_VER}-changelog" --rpm-summary "binutils-gcc${GCCSVN_VER} for centminmod.com LEMP stack installs" --rpm-dist ${DISTTAG}  -m "<centminmod.com>" --description "binutils-gcc${GCCSVN_VER} for centminmod.com LEMP stacks" --url https://centminmod.com --rpm-autoreqprov -p $DIR_TMP -C $BINUTIL_RPMINSTALLDIR

        # check provides and requires
        echo
        echo "-------------------------------------------------------------------------------------"
        echo "rpm -qp --provides \"${DIR_TMP}/binutils-gcc${GCCSVN_VER}-${BINUTILS_VER}-1.${DISTTAG}.x86_64.rpm\""
        rpm -qp --provides "${DIR_TMP}/binutils-gcc${GCCSVN_VER}-${BINUTILS_VER}-1.${DISTTAG}.x86_64.rpm"
        echo "-------------------------------------------------------------------------------------"
        echo
        
        echo
        echo "-------------------------------------------------------------------------------------"
        echo "rpm -qp --requires \"${DIR_TMP}/binutils-gcc${GCCSVN_VER}-${BINUTILS_VER}-1.${DISTTAG}.x86_64.rpm\""
        rpm -qp --requires "${DIR_TMP}/binutils-gcc${GCCSVN_VER}-${BINUTILS_VER}-1.${DISTTAG}.x86_64.rpm"
        echo "-------------------------------------------------------------------------------------"
        echo

        BINUTIL_RPMPATH="${DIR_TMP}/binutils-gcc${GCCSVN_VER}-${BINUTILS_VER}-1.${DISTTAG}.x86_64.rpm"
        ls -lah "$BINUTIL_RPMPATH"
        if [[ "$GCC_YUMINSTALL" = [yY] ]]; then
            echo
            echo "yum -y localinstall ${DIR_TMP}/binutils-gcc${GCCSVN_VER}-${BINUTILS_VER}-1.${DISTTAG}.x86_64.rpm"
            yum -y localinstall ${DIR_TMP}/binutils-gcc${GCCSVN_VER}-${BINUTILS_VER}-1.${DISTTAG}.x86_64.rpm
        fi
    else
        time make install
    fi
    if [[ "$GCC_YUMINSTALL" = [yY] ]]; then
        echo "${GCC_PREFIX}/bin/ld -v"
        ${GCC_PREFIX}/bin/ld -v
        echo "${GCC_PREFIX}/bin/ld.gold -v"
        ${GCC_PREFIX}/bin/ld.gold -v
        echo "${GCC_PREFIX}/bin/ld.bfd -v"
        ${GCC_PREFIX}/bin/ld.bfd -v
    fi
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
        GCCCFLAGS="-g ${OPT_LEVEL} -Wimplicit-fallthrough=0 -Wno-maybe-uninitialized -Wno-stringop-truncation"
        # export CXXFLAGS="${CFLAGS}"
        GCC_COMPILEOPTS="${GCC_COMPILEOPTS}${LTO_OPT}${GOLD_OPT}"
    else
        scl_install
        GCCSEVEN='y'
        source /opt/rh/devtoolset-7/enable
        GCCCFLAGS="-g ${OPT_LEVEL} -Wimplicit-fallthrough=0 -Wno-maybe-uninitialized -Wno-stringop-truncation"
        # export CXXFLAGS="${CFLAGS}"
        GCC_COMPILEOPTS="${GCC_COMPILEOPTS}${LTO_OPT}${GOLD_OPT}"
    fi
    if [[ "$GCC_PGO" = [yY] && "$BOOTCFLAGS" != [yY] ]]; then
        PGOTAG='-pgo'
        BOOTCFLAGS='y'
    elif [[ "$GCC_PGO" = [yY] && "$BOOTCFLAGS" = [yY] ]]; then
        PGOTAG='-pgo'
    elif [[ "$GCC_PGO" != [yY] ]]; then
        PGOTAG=""
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
        echo "cd ${DIR}${downloadtar_dirname}/test" | tee "${SCRIPT_DIR}/gcc${GCCSVN_VER}${PGOTAG}-fpm-cmd"
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
        if [[ "$GCC_PGO" = [yY] && "$BOOTCFLAGS" = [yY] && "$GCCSEVEN" = [Yy] ]]; then
            echo "time make${MAKETHREADS} profiledbootstrap BOOT_CFLAGS='${GCCCFLAGS}' CFLAGS_FOR_TARGET='${GCCCFLAGS}'"
            time make${MAKETHREADS} profiledbootstrap BOOT_CFLAGS="${GCCCFLAGS}" CFLAGS_FOR_TARGET="${GCCCFLAGS}"
        elif [[ "$GCC_PGO" = [yY] && "$BOOTCFLAGS" != [yY] && "$GCCSEVEN" = [Yy] ]]; then
            echo "time make${MAKETHREADS} profiledbootstrap"
            time make${MAKETHREADS} profiledbootstrap
        fi
    else
        if [[ "$BOOTCFLAGS" = [yY] && "$GCCSEVEN" = [Yy] ]]; then
            echo "time make${MAKETHREADS} BOOT_CFLAGS='${GCCCFLAGS}' CFLAGS_FOR_TARGET='${GCCCFLAGS}'"
            time make${MAKETHREADS} BOOT_CFLAGS="${GCCCFLAGS}" CFLAGS_FOR_TARGET="${GCCCFLAGS}"
        elif [[ "$BOOTCFLAGS" != [yY] && "$GCCSEVEN" = [Yy] ]]; then
            echo "time make${MAKETHREADS}"
            time make${MAKETHREADS}
        fi
    fi
    echo
    if [[ "$BUILTRPM" = [Yy] ]]; then
        echo "create GCC RPM package"
        GCC_RPMINSTALLDIR="/home/fpmtmp/gcc${GCCSVN_VER}_installdir"
        rm -rf $GCC_RPMINSTALLDIR
        rpm -e gcc${GCCSVN_VER}
        rpm -e gcc${GCCSVN_VER}${PGOTAG}
        echo "mkdir -p $GCC_RPMINSTALLDIR"
        mkdir -p $GCC_RPMINSTALLDIR
        echo "time make install DESTDIR=$GCC_RPMINSTALLDIR"
        time make install DESTDIR=$GCC_RPMINSTALLDIR
        # remove conflicting file with binutils
        echo "rm -rf $GCC_RPMINSTALLDIR${GCC_PREFIX}/share/info/dir"
        rm -rf $GCC_RPMINSTALLDIR${GCC_PREFIX}/share/info/dir
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

        # strip large binaries
        ginbin_list='cc1plus cc1 lto1'
        for g in ${ginbin_list[@]}; do
          echo
          echo "ls -lah "$GCC_RPMINSTALLDIR${GCC_PREFIX}/libexec/gcc/x86_64-redhat-linux/${GCCSVN_VER}/$g""
          ls -lah "$GCC_RPMINSTALLDIR${GCC_PREFIX}/libexec/gcc/x86_64-redhat-linux/${GCCSVN_VER}/$g"
          echo
          echo "strip "$GCC_RPMINSTALLDIR${GCC_PREFIX}/libexec/gcc/x86_64-redhat-linux/${GCCSVN_VER}/$g""
          strip "$GCC_RPMINSTALLDIR${GCC_PREFIX}/libexec/gcc/x86_64-redhat-linux/${GCCSVN_VER}/$g"
          echo
          echo "ls -lah "$GCC_RPMINSTALLDIR${GCC_PREFIX}/libexec/gcc/x86_64-redhat-linux/${GCCSVN_VER}/$g""
          ls -lah "$GCC_RPMINSTALLDIR${GCC_PREFIX}/libexec/gcc/x86_64-redhat-linux/${GCCSVN_VER}/$g"
          echo
        done

        ginrootbin_list="c++ cpp g++ gcc gcc-ar gcc-nm gcc-ranlib gcov gcov-dump gcov-tool x86_64-redhat-linux-c++ x86_64-redhat-linux-g++ x86_64-redhat-linux-gcc x86_64-redhat-linux-gcc-${GCCSVN_VER}"
        for gg in ${ginrootbin_list[@]}; do
          echo
          echo "ls -lah "$GCC_RPMINSTALLDIR${GCC_PREFIX}/bin/$gg""
          ls -lah "$GCC_RPMINSTALLDIR${GCC_PREFIX}/bin/$gg"
          echo
          echo "strip "$GCC_RPMINSTALLDIR${GCC_PREFIX}/bin/$gg""
          strip "$GCC_RPMINSTALLDIR${GCC_PREFIX}/bin/$gg"
          echo
          echo "ls -lah "$GCC_RPMINSTALLDIR${GCC_PREFIX}/bin/$gg""
          ls -lah "$GCC_RPMINSTALLDIR${GCC_PREFIX}/bin/$gg"
          echo
        done

        echo -e "* $(date +"%a %b %d %Y") George Liu <centminmod.com> ${GCCSVN_VER}\n - GCC ${GCCSVN_VER} for centminmod.com LEMP stack installs" > "gcc${GCCSVN_VER}-changelog"

        echo "fpm -f -s dir -t rpm -n gcc${GCCSVN_VER}${PGOTAG} -v $GCCFPM_VER $FPMCOMPRESS_OPT --rpm-changelog \"gcc${GCCSVN_VER}-changelog\" --rpm-summary \"gcc${GCCSVN_VER}${PGOTAG} for centminmod.com LEMP stack installs\" --after-install symlink.sh --before-remove remove_symlink.sh --rpm-dist ${DISTTAG}  -m \"<centminmod.com>\"  --description \"gcc${GCCSVN_VER}${PGOTAG} for centminmod.com LEMP stacks\" --url https://centminmod.com --rpm-autoreqprov -p $DIR_TMP -C $GCC_RPMINSTALLDIR" | tee -a "${SCRIPT_DIR}/gcc${GCCSVN_VER}${PGOTAG}-fpm-cmd"
        time fpm -f -s dir -t rpm -n gcc${GCCSVN_VER}${PGOTAG} -v $GCCFPM_VER $FPMCOMPRESS_OPT --rpm-changelog "gcc${GCCSVN_VER}-changelog" --rpm-summary "gcc${GCCSVN_VER}${PGOTAG} for centminmod.com LEMP stack installs" --after-install symlink.sh --before-remove remove_symlink.sh --rpm-dist ${DISTTAG}  -m "<centminmod.com>"  --description "gcc${GCCSVN_VER}${PGOTAG} for centminmod.com LEMP stacks" --url https://centminmod.com --rpm-autoreqprov -p $DIR_TMP -C $GCC_RPMINSTALLDIR

        # check provides and requires
        echo
        echo "-------------------------------------------------------------------------------------"
        echo "rpm -qp --provides \"${DIR_TMP}/gcc${GCCSVN_VER}${PGOTAG}-${GCCFPM_VER}-1.${DISTTAG}.x86_64.rpm\""
        rpm -qp --provides "${DIR_TMP}/gcc${GCCSVN_VER}${PGOTAG}-${GCCFPM_VER}-1.${DISTTAG}.x86_64.rpm"
        echo "-------------------------------------------------------------------------------------"
        echo
        
        echo
        echo "-------------------------------------------------------------------------------------"
        echo "rpm -qp --requires \"${DIR_TMP}/gcc${GCCSVN_VER}${PGOTAG}-${GCCFPM_VER}-1.${DISTTAG}.x86_64.rpm\""
        rpm -qp --requires "${DIR_TMP}/gcc${GCCSVN_VER}${PGOTAG}-${GCCFPM_VER}-1.${DISTTAG}.x86_64.rpm"
        echo "-------------------------------------------------------------------------------------"
        echo

        GCCRPM_PATH="${DIR_TMP}/gcc${GCCSVN_VER}${PGOTAG}-${GCCFPM_VER}-1.${DISTTAG}.x86_64.rpm"
        ls -lah "$GCCRPM_PATH"
        if [[ "$GCC_YUMINSTALL" = [yY] ]]; then
            echo
            echo "yum -y localinstall ${DIR_TMP}/gcc${GCCSVN_VER}${PGOTAG}-${GCCFPM_VER}-1.${DISTTAG}.x86_64.rpm"
            yum -y localinstall ${DIR_TMP}/gcc${GCCSVN_VER}${PGOTAG}-${GCCFPM_VER}-1.${DISTTAG}.x86_64.rpm
        fi
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

    if [[ "$GCC_YUMINSTALL" = [yY] ]]; then
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
    fi

    if [[ "$BUILTRPM" = [Yy] ]]; then
        echo
        echo "RPMs Built"
        echo "$BINUTIL_RPMPATH"
        echo "$GCCRPM_PATH"
        echo
        echo "ls -lah $DIR_TMP | egrep 'gcc${GCCSVN_VER}${PGOTAG}-${GCCFPM_VER}|binutils-gcc${GCCSVN_VER}-${BINUTILS_VER}'"
        ls -lah "$DIR_TMP" | egrep "gcc${GCCSVN_VER}${PGOTAG}-${GCCFPM_VER}|binutils-gcc${GCCSVN_VER}-${BINUTILS_VER}"
        if [[ "$GCC_YUMINSTALL" = [yY] ]]; then
            echo
            yum -q info "binutils-gcc${GCCSVN_VER}"
            echo
            rpm -qa --changelog "binutils-gcc${GCCSVN_VER}"
            echo
            yum -q info "gcc${GCCSVN_VER}${PGOTAG}"
            echo
            rpm -qa --changelog "gcc${GCCSVN_VER}${PGOTAG}"
        fi
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
            tidyup
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
            tidyup
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
            tidyup
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
            tidyup
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
            tidyup
            # postfixsetup
        } 2>&1 | tee "${CENTMINLOGDIR}/tools-gcc-install${PGOTAG}_${DT}.log"
            endtime=$(TZ=UTC date +%s.%N)
            INSTALLTIME=$(echo "scale=2;$endtime - $starttime"|bc )
            echo "" >> "${CENTMINLOGDIR}/tools-gcc-install${PGOTAG}_${DT}.log"
            echo "Total Binutils + GCC Install Time: $INSTALLTIME seconds" >> "${CENTMINLOGDIR}/tools-gcc-install${PGOTAG}_${DT}.log"
            tail -2 "${CENTMINLOGDIR}/tools-gcc-install${PGOTAG}_${DT}.log"
        ;;
    installpgo7 )
        GCCSVN_VER='7'
        GCC_PGO='y'
        BOOTCFLAGS='y'
            starttime=$(TZ=UTC date +%s.%N)
        {
            fpm_install
            binutils_install
            install_gcc
            tidyup
            # postfixsetup
        } 2>&1 | tee "${CENTMINLOGDIR}/tools-gcc-install${PGOTAG}_${DT}.log"
            endtime=$(TZ=UTC date +%s.%N)
            INSTALLTIME=$(echo "scale=2;$endtime - $starttime"|bc )
            echo "" >> "${CENTMINLOGDIR}/tools-gcc-install${PGOTAG}_${DT}.log"
            echo "Total Binutils + GCC Install Time: $INSTALLTIME seconds" >> "${CENTMINLOGDIR}/tools-gcc-install${PGOTAG}_${DT}.log"
            tail -2 "${CENTMINLOGDIR}/tools-gcc-install${PGOTAG}_${DT}.log"
        ;;
    installpgo8 )
        GCCSVN_VER='8'
        GCC_PGO='y'
        BOOTCFLAGS='y'
            starttime=$(TZ=UTC date +%s.%N)
        {
            fpm_install
            binutils_install
            install_gcc
            tidyup
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
            tidyup
            # postfixsetup
        } 2>&1 | tee "${CENTMINLOGDIR}/tools-gcc-install${PGOTAG}_${DT}.log"
            endtime=$(TZ=UTC date +%s.%N)
            INSTALLTIME=$(echo "scale=2;$endtime - $starttime"|bc )
            echo "" >> "${CENTMINLOGDIR}/tools-gcc-install${PGOTAG}_${DT}.log"
            echo "Total GCC Install Time: $INSTALLTIME seconds" >> "${CENTMINLOGDIR}/tools-gcc-install${PGOTAG}_${DT}.log"
            tail -2 "${CENTMINLOGDIR}/tools-gcc-install${PGOTAG}_${DT}.log"
        ;;
    installgcc7 )
        GCCSVN_VER='7'
            starttime=$(TZ=UTC date +%s.%N)
        {
            fpm_install
            install_gcc
            tidyup
            # postfixsetup
        } 2>&1 | tee "${CENTMINLOGDIR}/tools-gcc-install${PGOTAG}_${DT}.log"
            endtime=$(TZ=UTC date +%s.%N)
            INSTALLTIME=$(echo "scale=2;$endtime - $starttime"|bc )
            echo "" >> "${CENTMINLOGDIR}/tools-gcc-install${PGOTAG}_${DT}.log"
            echo "Total GCC Install Time: $INSTALLTIME seconds" >> "${CENTMINLOGDIR}/tools-gcc-install${PGOTAG}_${DT}.log"
            tail -2 "${CENTMINLOGDIR}/tools-gcc-install${PGOTAG}_${DT}.log"
        ;;
    installgcc8 )
        GCCSVN_VER='8'
            starttime=$(TZ=UTC date +%s.%N)
        {
            fpm_install
            install_gcc
            tidyup
            # postfixsetup
        } 2>&1 | tee "${CENTMINLOGDIR}/tools-gcc-install${PGOTAG}_${DT}.log"
            endtime=$(TZ=UTC date +%s.%N)
            INSTALLTIME=$(echo "scale=2;$endtime - $starttime"|bc )
            echo "" >> "${CENTMINLOGDIR}/tools-gcc-install${PGOTAG}_${DT}.log"
            echo "Total GCC Install Time: $INSTALLTIME seconds" >> "${CENTMINLOGDIR}/tools-gcc-install${PGOTAG}_${DT}.log"
            tail -2 "${CENTMINLOGDIR}/tools-gcc-install${PGOTAG}_${DT}.log"
        ;;
    installpgogcc7 )
        GCCSVN_VER='7'
        GCC_PGO='y'
        BOOTCFLAGS='y'
            starttime=$(TZ=UTC date +%s.%N)
        {
            fpm_install
            install_gcc
            tidyup
            # postfixsetup
        } 2>&1 | tee "${CENTMINLOGDIR}/tools-gcc-install${PGOTAG}_${DT}.log"
            endtime=$(TZ=UTC date +%s.%N)
            INSTALLTIME=$(echo "scale=2;$endtime - $starttime"|bc )
            echo "" >> "${CENTMINLOGDIR}/tools-gcc-install${PGOTAG}_${DT}.log"
            echo "Total GCC Install Time: $INSTALLTIME seconds" >> "${CENTMINLOGDIR}/tools-gcc-install${PGOTAG}_${DT}.log"
            tail -2 "${CENTMINLOGDIR}/tools-gcc-install${PGOTAG}_${DT}.log"
        ;;
    installpgogcc8 )
        GCCSVN_VER='8'
        GCC_PGO='y'
        BOOTCFLAGS='y'
            starttime=$(TZ=UTC date +%s.%N)
        {
            fpm_install
            install_gcc
            tidyup
            # postfixsetup
        } 2>&1 | tee "${CENTMINLOGDIR}/tools-gcc-install${PGOTAG}_${DT}.log"
            endtime=$(TZ=UTC date +%s.%N)
            INSTALLTIME=$(echo "scale=2;$endtime - $starttime"|bc )
            echo "" >> "${CENTMINLOGDIR}/tools-gcc-install${PGOTAG}_${DT}.log"
            echo "Total GCC Install Time: $INSTALLTIME seconds" >> "${CENTMINLOGDIR}/tools-gcc-install${PGOTAG}_${DT}.log"
            tail -2 "${CENTMINLOGDIR}/tools-gcc-install${PGOTAG}_${DT}.log"
        ;;
    * )
        echo
        echo "Usage:"
        echo
        echo "$0 {install|install7|install8|installpgo7|installpgo8|installgcc|installgcc7|installgcc8|installpgogcc7|installpgogcc8|binutils7|binutils8}"
        ;;
esac
