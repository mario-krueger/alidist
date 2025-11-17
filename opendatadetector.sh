package: OpenDataDetector
version: "main"
requires:
  - ROOT
  - GEANT4
  - HepMC3
build_requires:
  - "Clang:(?!osx)"
  - CMake
  - DD4Hep
  - alibuild-recipe-tools
source: https://gitlab.cern.ch/acts/OpenDataDetector.git
---
#!/bin/bash -ex

# cmake -S $SOURCEDIR -B ./  -DDD4hep_DIR=$HOME/alice/sw/SOURCES/DD4Hep/master/master/cmake/ -DGeant4_DIR=$GEANT4_ROOT -DROOT_DIR=$ROOTSYS -DCMAKE_CXX_STANDARD=17
cmake -S $SOURCEDIR -B ./  -DDD4hep_DIR=$DD4HEP_ROOT -DGeant4_DIR=$GEANT4_ROOT -DROOT_DIR=$ROOTSYS -DCMAKE_CXX_STANDARD=17 -DCMAKE_INSTALL_PREFIX=$INSTALLROOT

# cmake --build . -- ${JOBS:+-j$JOBS} install
cmake --build . -- ${JOBS:+-j$JOBS}


# cmake -S <path_to_source> -B <path_to_build_area>  -DDD4hep_DIR=<path_to_DD4hp> cmake -DGeant4_DIR=<path_to_Geant4> -DROOT_DIR=<path_to_ROOT> -DCMAKE_CXX_STANDARD=17
# cmake --build <path_to_build_area>


[[ -d $INSTALLROOT/lib64 ]] && [[ ! -d $INSTALLROOT/lib ]] && ln -sf ${INSTALLROOT}/lib64 $INSTALLROOT/lib

#ModuleFile
MODULEDIR="${INSTALLROOT}/etc/modulefiles"
MODULEFILE="${MODULEDIR}/${PKGNAME}"
mkdir -p ${MODULEDIR}
alibuild-generate-module --bin --lib > "${MODULEFILE}"
# extra environment
cat >> ${MODULEFILE} <<EOF
set ODD_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
setenv ODD_ROOT \$ODD_ROOT
prepend-path ROOT_INCLUDE_PATH \$ODD_ROOT/include
EOF
