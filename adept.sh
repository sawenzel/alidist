package: AdePT
version: "v0.4.3-3-gd04a3e0"
tag: d04a3e020013ba66bba37381d29db1fa742d955d
source: https://github.com/apt-sim/AdePT.git
requires:
  - "GCC-Toolchain:(?!osx)"
  - VecGeom
  - GEANT4
  - G4HepEm
  - G4VG
build_requires:
  - CMake
  - ninja
  - alibuild-recipe-tools
---
#!/bin/bash -e
# CUDA is a system install; set ADEPT_CUDA_ARCH to match the GPU (120 = Blackwell).
: ${CUDA_ROOT:=/etc/alternatives/cuda}
export PATH=$CUDA_ROOT/bin:$PATH
: ${ADEPT_CUDA_ARCH:=120}

cmake "$SOURCEDIR" -GNinja                                \
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"                   \
  -DCMAKE_INSTALL_LIBDIR=lib                              \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo                       \
  -DCMAKE_CUDA_COMPILER=$CUDA_ROOT/bin/nvcc               \
  -DCMAKE_CUDA_ARCHITECTURES=$ADEPT_CUDA_ARCH             \
  -DCUDAToolkit_ROOT=$CUDA_ROOT                           \
  -DCMAKE_PREFIX_PATH="$VECGEOM_ROOT;$GEANT4_ROOT;$G4HEPEM_ROOT;$G4VG_ROOT" \
  -DADEPT_USE_BUILTIN_G4VG=OFF                            \
  -DADEPT_USE_SURF=OFF                                    \
  -DADEPT_BUILD_EXAMPLES=ON                               \
  -DADEPT_BUILD_TESTING=ON                                \
  -DBUILD_TESTING=ON                                      \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON                      \
  ${CXXSTD:+-DCMAKE_CXX_STANDARD=$CXXSTD}

cmake --build . -- ${JOBS:+-j $JOBS} install

# Modulefile
MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
alibuild-generate-module --bin --lib > "$MODULEFILE"
cat >> "$MODULEFILE" <<EOF2
# extra environment
set ADEPT_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
setenv ADEPT_ROOT \$ADEPT_ROOT
EOF2
