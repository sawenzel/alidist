package: g4navigatorlogger
version: "%(tag_basename)s"
tag: master
source: https://swenzel@bitbucket.org/swenzel/g4navigatorlogger.git
requires:
  - "GCC-Toolchain:(?!osx)"
  - ROOT
build_requires:
  - CMake
---

#!/bin/bash -e
cmake $SOURCEDIR -DCMAKE_INSTALL_PREFIX=$INSTALLROOT   \
          ${CXXSTD:+-DCMAKE_CXX_STANDARD=$CXXSTD}      \
          -DCMAKE_EXPORT_COMPILE_COMMANDS=ON

make ${JOBS+-j $JOBS}
make install

# Modulefile
MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
cat > "$MODULEFILE" <<EoF
#%Module1.0
proc ModulesHelp { } {
  global version
  puts stderr "ALICE Modulefile for $PKGNAME $PKGVERSION-@@PKGREVISION@$PKGHASH@@"
}
set version $PKGVERSION-@@PKGREVISION@$PKGHASH@@
module-whatis "ALICE Modulefile for $PKGNAME $PKGVERSION-@@PKGREVISION@$PKGHASH@@"
# Dependencies
module load BASE/1.0 ${ROOT_VERSION:+ROOT/$ROOT_VERSION-$ROOT_REVISION}
# Our environment
set osname [uname sysname]
setenv G4NAVIGATORLOGGER_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path LD_LIBRARY_PATH \$::env(G4NAVIGATORLOGGER_ROOT)/lib
prepend-path PATH \$::env(G4NAVIGATORLOGGER_ROOT)/bin
prepend-path ROOT_INCLUDE_PATH \$::env(G4NAVIGATORLOGGER_ROOT)/include
EoF
