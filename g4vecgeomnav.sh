package: G4VecGeomNav
version: "%(tag_basename)s"
tag: "master"
source: https://gitlab.cern.ch/VecGeom/g4vecgeomnav.git
requires:
  - "GCC-Toolchain:(?!osx)"
  - VecGeom
  - GEANT4
build_requires:
  - CMake
  - ninja
  - alibuild-recipe-tools
---

#!/bin/bash -e
unset CXXFLAGS
export CXXFLAGS="-fPIC -O2 -std=c++17 -W -Wall -pedantic -Wno-non-virtual-dtor -Wno-long-long -Wwrite-strings -Wpointer-arith -Woverloaded-virtual -Wno-variadic-macros -Wshadow"
cmake $SOURCEDIR -DCMAKE_INSTALL_PREFIX=$INSTALLROOT            \
      ${CXXSTD:+-DCMAKE_CXX_STANDARD=$CXXSTD}                   \
      -DCMAKE_EXPORT_COMPILE_COMMANDS=ON

cmake --build . -- ${JOBS+-j $JOBS} install

# Modulefile
MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
alibuild-generate-module --bin --lib > $MODULEFILE
cat >> "$MODULEFILE" <<EOF
# extra environment
set G4VECGEOM_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
EOF
