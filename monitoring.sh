package: Monitoring
version: "%(tag_basename)s"
tag: v3.10.1
requires:
  - boost
  - "GCC-Toolchain:(?!osx)"
  - "ApMon-CPP:(?!osx)"
  - "system-curl:(slc8)"
  - "curl:(?!slc8)"
  - libInfoLogger
build_requires:
  - CMake
  - alibuild-recipe-tools
source: https://github.com/AliceO2Group/Monitoring
incremental_recipe: |
  make ${JOBS:+-j$JOBS} install
  mkdir -p $INSTALLROOT/etc/modulefiles && rsync -a --delete etc/modulefiles/ $INSTALLROOT/etc/modulefiles
---
#!/bin/bash -ex

case $ARCHITECTURE in
    osx*) [[ ! $BOOST_ROOT ]] && BOOST_ROOT=$(brew --prefix boost);;
esac

if [[ $ALIBUILD_O2_TESTS ]]; then
  CXXFLAGS="${CXXFLAGS} -Werror -Wno-error=deprecated-declarations"
fi

cmake $SOURCEDIR                                              \
      -DCMAKE_INSTALL_PREFIX=$INSTALLROOT                     \
      ${BOOST_REVISION:+-DBOOST_ROOT=$BOOST_ROOT}                 \
      ${APMON_CPP_REVISION:+-DAPMON_ROOT=$APMON_CPP_ROOT}         \
      -DCMAKE_EXPORT_COMPILE_COMMANDS=ON 

cp ${BUILDDIR}/compile_commands.json ${INSTALLROOT}

make ${JOBS+-j $JOBS} install

if [[ $ALIBUILD_O2_TESTS ]]; then
  ctest --output-on-failure
fi


#ModuleFile
mkdir -p etc/modulefiles
alibuild-generate-module --bin --lib > etc/modulefiles/$PKGNAME
cat >> etc/modulefiles/$PKGNAME <<EoF
# Our environment
set MONITORING_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
EoF
mkdir -p $INSTALLROOT/etc/modulefiles && rsync -a --delete etc/modulefiles/ $INSTALLROOT/etc/modulefiles
