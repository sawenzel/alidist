package: g4vecgeom
version: "%(tag_basename)s"
tag: master
source: https://swenzel@bitbucket.org/swenzel/g4vecgeom.git
requires:
  - "GCC-Toolchain:(?!osx)"
  - "Vc"
  - ROOT
  - VecGeom
  - GEANT4
build_requires:
  - CMake
---

#!/bin/bash -e
cmake $SOURCEDIR/g4vecgeom -DCMAKE_INSTALL_PREFIX=$INSTALLROOT ${CXXSTD:+-DCMAKE_CXX_STANDARD=$CXXSTD}               \
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
module load BASE/1.0 Vc/$VC_VERSION-$VC_REVISION ${ROOT_VERSION:+ROOT/$ROOT_VERSION-$ROOT_REVISION} ${GEANT4_VERSION:+GEANT4/$GEANT4_VERSION-$GEANT4_REVISION}

# Our environment
set osname [uname sysname]
setenv G4VECGEOM_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path PATH \$::env(G4VECGEOM_ROOT)/bin
prepend-path LD_LIBRARY_PATH \$::env(G4VECGEOM_ROOT)/lib
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH \$::env(G4VECGEOM_ROOT)/lib")
EoF
