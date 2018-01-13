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

GCC_SVN='y'
GCC_VER='7.2.0'
GCC_PREFIX="/opt/gcc-${GCC_VER}"
BINUTILS_VER='2.29.1'

DIR_TMP='/svr-setup'
CENTMINLOGDIR='/root/centminlogs'
GCC_SNAPSHOTSEVEN='http://www.netgull.com/gcc/snapshots/LATEST-7/'
GCC_SNAPSHOTEIGHT='http://www.netgull.com/gcc/snapshots/LATEST-8/'
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

binutils_install() {

cd $DIR_TMP
if [[ ! -f "binutils-${BINUTILS_VER}.tar.gz" || ! -d "binutils-${BINUTILS_VER}" ]]; then
  wget -cnv "https://ftp.gnu.org/gnu/binutils/binutils-${BINUTILS_VER}.tar.gz"
  tar xvzf "binutils-${BINUTILS_VER}.tar.gz"
fi
    rm -rf gold.binutils
    mkdir -p gold.binutils
    cd gold.binutils
    ../binutils-${BINUTILS_VER}/configure --prefix="$GCC_PREFIX" --enable-gold --enable-plugins --disable-nls --disable-werror
    time make${MAKETHREADS} all-gold
    time make${MAKETHREADS}
    time make install
    echo "${GCC_PREFIX}/bin/ld -v"
    ${GCC_PREFIX}/bin/ld -v
    echo "${GCC_PREFIX}/bin/ld.gold -v"
    ${GCC_PREFIX}/bin/ld.gold -v
    echo "${GCC_PREFIX}/bin/ld.bfd -v"
    ${GCC_PREFIX}/bin/ld.bfd -v
}

sourcesetup() {
    echo "*************************************************"
    cecho "* Setup ${GCC_PREFIX}/enable" $boldgreen
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
    cecho "* Setup ${GCC_PREFIX}/enable completed" $boldgreen
    echo "*************************************************"
    echo
}

install_gcc() {

    echo "*************************************************"
    cecho "* Compile GCC Start..." $boldgreen
    echo "*************************************************"
    echo

    pkgs='gmp-devel mpfr-devel libmpc-devel'
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
        echo "../gcc-${GCC_VER}/configure --prefix=$GCC_PREFIX --disable-multilib"
        ../gcc-${GCC_VER}/configure --prefix="$GCC_PREFIX" --disable-multilib
    elif [[ "$GCC_SVN" = [yY] ]]; then
        downloadtar_name=$(curl -4s http://www.netgull.com/gcc/snapshots/LATEST-7/ | grep -o '<a .*href=.*>' | sed -e 's/<a /\n<a /g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' | awk -F "/" '/tar.xz/ {print $2}')
        downloadtar_dirname=$(echo "$downloadtar_name" | sed -e 's|.tar.xz||')
        rm -rf "${downloadtar_dirname}*"
        echo "wget "$GCC_SNAPSHOTSEVEN/${downloadtar_name}""
        wget "$GCC_SNAPSHOTSEVEN/${downloadtar_name}"
        echo "tar xf ${downloadtar_name}"
        tar xf "${downloadtar_name}"
        cd "$downloadtar_dirname"
        echo "mkdir -p test"
        mkdir -p test
        cd test
        GCC_PREFIX="/opt/${downloadtar_dirname}"
        echo "../configure --prefix=$GCC_PREFIX --disable-multilib"
        ../configure --prefix="$GCC_PREFIX" --disable-multilib --disable-nls
    fi
    echo
    echo "time make${MAKETHREADS}"
    time make${MAKETHREADS}
    echo
    echo "time make install"
    time make install
    echo
    sourcesetup
    echo
    echo "${GCC_PREFIX}/bin/ld -v"
    "${GCC_PREFIX}/bin/ld -v"
    echo "${GCC_PREFIX}/bin/ld.gold -v"
    "${GCC_PREFIX}/bin/ld.gold -v"
    echo "${GCC_PREFIX}/bin/ld.bfd -v"
    "${GCC_PREFIX}/bin/ld.bfd -v"
    echo "${GCC_PREFIX}/bin/gcc --version"
    "${GCC_PREFIX}/bin/gcc --version"
    echo "${GCC_PREFIX}/bin/g++ --version"
    "${GCC_PREFIX}/bin/g++ --version"

    echo "*************************************************"
    cecho "* Compile GCC Completed" $boldgreen
    echo "*************************************************"
}

#########################
case "$1" in
    install )
        {
            starttime=$(TZ=UTC date +%s.%N)
            binutils_install
            install_gcc
            # postfixsetup
        } 2>&1 | tee "${CENTMINLOGDIR}/tools-gcc-install_${DT}.log"
            endtime=$(TZ=UTC date +%s.%N)
            INSTALLTIME=$(echo "scale=2;$endtime - $starttime"|bc )
            echo "" >> "${CENTMINLOGDIR}/tools-gcc-install_${DT}.log"
            echo "Total Binutils + GCC Install Time: $INSTALLTIME seconds" >> "${CENTMINLOGDIR}/tools-gcc-install_${DT}.log"
        ;;
    * )
        echo "Usage:"
        echo "$0 {install}"
        ;;
esac
