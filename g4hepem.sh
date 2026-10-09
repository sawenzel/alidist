package: G4HepEm
version: "%(tag_basename)s"
tag: master
source: https://github.com/mnovak42/g4hepem.git
requires:
  - "GCC-Toolchain:(?!osx)"
  - GEANT4
build_requires:
  - CMake
  - ninja
  - alibuild-recipe-tools
---
#!/bin/bash -e
# CUDA is a system install (see project .claude/settings.json); make nvcc visible.
: ${CUDA_ROOT:=/etc/alternatives/cuda}
export PATH=$CUDA_ROOT/bin:$PATH
# Override with G4HEPEM_CUDA_ARCH=... if the target GPU differs.
# Default 120 = NVIDIA Blackwell (RTX PRO 6000 Blackwell, sm_120) on this host.
: ${G4HEPEM_CUDA_ARCH:=120}

cmake $SOURCEDIR                                          \
  -DCMAKE_INSTALL_PREFIX=$INSTALLROOT                     \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo                       \
  -DBUILD_SHARED_LIBS=ON                                  \
  -DG4HepEm_CUDA_BUILD=ON                                 \
  -DG4HepEm_EARLY_TRACKING_EXIT=ON                        \
  -DCMAKE_CUDA_COMPILER=$CUDA_ROOT/bin/nvcc              \
  -DCMAKE_CUDA_ARCHITECTURES=$G4HEPEM_CUDA_ARCH          \
  -DCUDAToolkit_ROOT=$CUDA_ROOT                           \
  -DCMAKE_PREFIX_PATH="$GEANT4_ROOT"                      \
  ${CXXSTD:+-DCMAKE_CXX_STANDARD=$CXXSTD}                 \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON                      \
  -GNinja

cmake --build . -- ${JOBS:+-j $JOBS} install

# Modulefile
MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
alibuild-generate-module --lib > "$MODULEFILE"
cat >> "$MODULEFILE" <<EOF
# extra environment
set G4HepEm_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
setenv G4HepEm_ROOT \$G4HepEm_ROOT
EOF
