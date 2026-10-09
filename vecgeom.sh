package: VecGeom
version: "%(tag_basename)s"
tag: master
source: https://gitlab.cern.ch/VecGeom/VecGeom.git
requires:
  - "GCC-Toolchain:(?!osx)"
  - xercesc
license: Apache-2.0
build_requires:
  - CMake
  - ninja
  - alibuild-recipe-tools
---
#!/bin/bash -e
# VecGeom master (2.1.1-dev) with CUDA, for AdePT.
# AdePT requires VecGeom >= 2.0.0-dev.5, so the v1.2.6 tag used elsewhere in
# alidist cannot serve here.
# CUDA is a system install; make nvcc visible.
: ${CUDA_ROOT:=/etc/alternatives/cuda}
export PATH=$CUDA_ROOT/bin:$PATH
# Override with VECGEOM_CUDA_ARCH=... to match the target GPU.
# Default 120 = NVIDIA Blackwell (RTX PRO 6000 Blackwell, sm_120) on this host.
: ${VECGEOM_CUDA_ARCH:=120}

cmake $SOURCEDIR                                          \
  -DCMAKE_INSTALL_PREFIX=$INSTALLROOT                     \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo                       \
  -DBUILD_SHARED_LIBS=ON                                  \
  -DVECGEOM_BACKEND=Scalar                                \
  -DVECGEOM_BUILTIN_VECCORE=ON                            \
  -DVECGEOM_ENABLE_CUDA=ON                                \
  -DCMAKE_CUDA_COMPILER=$CUDA_ROOT/bin/nvcc               \
  -DCMAKE_CUDA_ARCHITECTURES=$VECGEOM_CUDA_ARCH           \
  -DCUDAToolkit_ROOT=$CUDA_ROOT                           \
  -DVECGEOM_NAV=index                                     \
  -DVECGEOM_GDML=ON                                       \
  -DCMAKE_PREFIX_PATH="$XERCESC_ROOT"                     \
  -DBUILD_TESTING=OFF                                     \
  -DBENCHMARK=OFF                                         \
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
set VECGEOM_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
setenv VECGEOM_ROOT \$VECGEOM_ROOT
EOF
