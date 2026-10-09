package: AdePT
version: "%(tag_basename)s"
tag: master
source: https://github.com/apt-sim/AdePT.git
requires:
  - "GCC-Toolchain:(?!osx)"
  - VecGeom
  - GEANT4
  - G4HepEm
  - HepMC3
  - G4VecGeomNav
build_requires:
  - CMake
  - ninja
  - alibuild-recipe-tools
---
#!/bin/bash -e
# CUDA is a system install (see project .claude/settings.json); make nvcc visible.
: ${CUDA_ROOT:=/etc/alternatives/cuda}
export PATH=$CUDA_ROOT/bin:$PATH
# Override with ADEPT_CUDA_ARCH=... to match the target GPU.
# Default 120 = NVIDIA Blackwell (RTX PRO 6000 Blackwell, sm_120) on this host.
: ${ADEPT_CUDA_ARCH:=120}

cmake $SOURCEDIR                                          \
  -DCMAKE_INSTALL_PREFIX=$INSTALLROOT                     \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo                       \
  -DCMAKE_CUDA_COMPILER=$CUDA_ROOT/bin/nvcc              \
  -DCMAKE_CUDA_ARCHITECTURES=$ADEPT_CUDA_ARCH            \
  -DCUDAToolkit_ROOT=$CUDA_ROOT                           \
  -DCMAKE_PREFIX_PATH="$VECGEOM_ROOT:$GEANT4_ROOT:$G4HepEm_ROOT:$HEPMC3_ROOT:$G4VECGEOMNAV_ROOT" \
  -DADEPT_USE_SURF=OFF                                    \
  -DADEPT_BUILD_EXAMPLES=ON                               \
  -DBUILD_TESTING=ON                                      \
  ${CXXSTD:+-DCMAKE_CXX_STANDARD=$CXXSTD}                 \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON                      \
  -GNinja

cmake --build . -- ${JOBS:+-j $JOBS} install

# Modulefile
MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
alibuild-generate-module --bin --lib > "$MODULEFILE"
cat >> "$MODULEFILE" <<EOF
# extra environment
set ADEPT_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
setenv ADEPT_ROOT \$ADEPT_ROOT
EOF
