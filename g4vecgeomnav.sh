package: G4VecGeomNav
version: "%(tag_basename)s"
tag: master
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
# VecGeom navigation for Geant4, built against the CUDA-enabled VecGeom that AdePT uses.
: ${CUDA_ROOT:=/etc/alternatives/cuda}
export PATH=$CUDA_ROOT/bin:$PATH

cmake $SOURCEDIR                                          \
  -DCMAKE_INSTALL_PREFIX=$INSTALLROOT                     \
  -DCMAKE_INSTALL_LIBDIR=lib                              \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo                       \
  -DBUILD_NAV_TEST=ON                                     \
  -DCMAKE_EXE_LINKER_FLAGS="-Wl,--no-as-needed $VECGEOM_ROOT/lib64/libvecgeom_final.so -Wl,--as-needed" \
  -DCMAKE_CUDA_COMPILER=$CUDA_ROOT/bin/nvcc               \
  -DCUDAToolkit_ROOT=$CUDA_ROOT                           \
  -DCMAKE_PREFIX_PATH="$VECGEOM_ROOT;$GEANT4_ROOT;$XERCESC_ROOT" \
  ${CXXSTD:+-DCMAKE_CXX_STANDARD=$CXXSTD}                 \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON                      \
  -GNinja

cmake --build . -- ${JOBS:+-j $JOBS} install

# Modulefile
MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
alibuild-generate-module --bin --lib > "$MODULEFILE"
cat >> "$MODULEFILE" <<EOT
# extra environment
set G4VECGEOMNAV_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
setenv G4VECGEOMNAV_ROOT \$G4VECGEOMNAV_ROOT
prepend-path PATH \$G4VECGEOMNAV_ROOT/bin/examples/FullCMS
EOT
