package: G4VG
version: "%(tag_basename)s"
tag: v1.0.7
source: https://github.com/celeritas-project/g4vg
requires:
  - "GCC-Toolchain:(?!osx)"
  - GEANT4
  - VecGeom
license: Apache-2.0
build_requires:
  - CMake
  - ninja
  - alibuild-recipe-tools
---
#!/bin/bash -e
cmake "$SOURCEDIR" -GNinja                              \
      -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"             \
      -DCMAKE_INSTALL_LIBDIR=lib                        \
      -DCMAKE_BUILD_TYPE=RelWithDebInfo                 \
      -DBUILD_SHARED_LIBS=ON                            \
      -DG4VG_BUILD_TESTS=OFF                            \
      -DCMAKE_PREFIX_PATH="$GEANT4_ROOT;$VECGEOM_ROOT"  \
      ${CXXSTD:+-DCMAKE_CXX_STANDARD=$CXXSTD}

cmake --build . -- ${JOBS+-j $JOBS} install

# Modulefile
MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
alibuild-generate-module --lib > $MODULEFILE
cat >> "$MODULEFILE" <<EOF2
# extra environment
set G4VG_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
setenv G4VG_ROOT \$G4VG_ROOT
EOF2
