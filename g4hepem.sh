package: G4HepEm
version: "%(tag_basename)s"
tag: 20261106-alice1
source: https://github.com/sawenzel/g4hepem
requires:
  - GEANT4
license: Apache-2.0
build_requires:
  - CMake
  - ninja
  - alibuild-recipe-tools
---
#!/bin/bash -e
# CUDA build for AdePT; geant4_vmc links the same library, since the CPU and
# CUDA builds differ in the layout of G4HepEmParameters.
: ${CUDA_ROOT:=/etc/alternatives/cuda}
export PATH=$CUDA_ROOT/bin:$PATH
: ${G4HEPEM_CUDA_ARCH:=120}

cmake "$SOURCEDIR" -GNinja                    \
      -DG4HepEm_CUDA_BUILD=ON                 \
      -DG4HepEm_EARLY_TRACKING_EXIT=ON        \
      -DCMAKE_CUDA_COMPILER=$CUDA_ROOT/bin/nvcc \
      -DCMAKE_CUDA_ARCHITECTURES=$G4HEPEM_CUDA_ARCH \
      -DCUDAToolkit_ROOT=$CUDA_ROOT           \
      -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"   \
      -DCMAKE_INSTALL_LIBDIR=lib              \
      -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}  \
      -DBUILD_SHARED_LIBS=ON                  \
      -DBUILD_TESTING=OFF                     \
      ${CXXSTD:+-DCMAKE_CXX_STANDARD=$CXXSTD}

cmake --build . -- ${JOBS+-j $JOBS} install

# Modulefile
MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
alibuild-generate-module --lib > $MODULEFILE
cat >> "$MODULEFILE" <<EoF
# extra environment
set G4HEPEM_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
setenv G4HEPEM_ROOT \$G4HEPEM_ROOT
EoF
