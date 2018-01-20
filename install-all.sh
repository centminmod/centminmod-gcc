#!/bin/bash
##########################################
# install & generate both GCC 7 & 8 RPM
# for both non-PGO + PGO builds
##########################################
DT=$(date +"%d%m%y-%H%M%S")
DIR_TMP='/svr-setup'
CENTMINLOGDIR='/root/centminlogs'
GCC_PGO='y'
GCC_EIGHTONLY='n'

build() {
if [[ -f install.sh ]]; then
  if [[ "$GCC_EIGHTONLY" != [yY] ]]; then
    echo
    echo "----------------------------------------------------------------"
    echo "./install.sh binutils7"
    ./install.sh binutils7
  
    echo
    echo "----------------------------------------------------------------"
    echo "./install.sh installgcc7"
    ./install.sh installgcc7
  
    if [[ "$GCC_PGO" = [yY] ]]; then
      echo
      echo "----------------------------------------------------------------"
      echo "./install.sh installpgogcc7"
      ./install.sh installpgogcc7
    fi
  fi

  echo
  echo "----------------------------------------------------------------"
  echo "./install.sh binutils8"
  ./install.sh binutils8

  echo
  echo "----------------------------------------------------------------"
  echo "./install.sh installgcc8"
  ./install.sh installgcc8

  if [[ "$GCC_PGO" = [yY] ]]; then
    echo
    echo "----------------------------------------------------------------"
    echo "./install.sh installpgogcc8"
    ./install.sh installpgogcc8
  fi
fi

  echo "ls -lah $DIR_TMP | egrep 'gcc[7,8]|binutils-gcc' | grep rpm"
  ls -lah "$DIR_TMP" | egrep 'gcc[7,8]|binutils-gcc' | grep rpm

}

  starttime=$(TZ=UTC date +%s.%N)
  {
  build
  } 2>&1 | tee "${CENTMINLOGDIR}/tools-gcc-install-all_${DT}.log"
  endtime=$(TZ=UTC date +%s.%N)
  INSTALLTIME=$(echo "scale=2;$endtime - $starttime"|bc )
  echo "" >> "${CENTMINLOGDIR}/tools-gcc-install-all_${DT}.log"
  echo "Total Run Time: $INSTALLTIME seconds" >> "${CENTMINLOGDIR}/tools-gcc-install-all_${DT}.log"
  tail -2 "${CENTMINLOGDIR}/tools-gcc-install-all_${DT}.log"
exit
