package: VecGeom
version: "%(tag_basename)s"
tag: v2.2.1
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
# VecGeom with the Scalar backend and CUDA, shared by O2 and AdePT.
# CUDA is a system install; set VECGEOM_CUDA_ARCH to match the GPU (120 = Blackwell).
: ${CUDA_ROOT:=/etc/alternatives/cuda}
export PATH=$CUDA_ROOT/bin:$PATH
: ${VECGEOM_CUDA_ARCH:=120}

cmake "$SOURCEDIR" -GNinja                                \
      -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"               \
      -DCMAKE_INSTALL_LIBDIR=lib                          \
      -DCMAKE_BUILD_TYPE=RelWithDebInfo                   \
      -DBUILD_SHARED_LIBS=ON                              \
      -DVECGEOM_BACKEND=Scalar                            \
      -DVECGEOM_BUILTIN_VECCORE=ON                        \
      -DVECGEOM_ENABLE_CUDA=ON                            \
      -DVECGEOM_NAV=index                                 \
      -DVECGEOM_GDML=ON                                   \
      -DCMAKE_CUDA_COMPILER=$CUDA_ROOT/bin/nvcc           \
      -DCMAKE_CUDA_ARCHITECTURES=$VECGEOM_CUDA_ARCH       \
      -DCUDAToolkit_ROOT=$CUDA_ROOT                       \
      -DBENCHMARK=OFF                                     \
      -DBUILD_TESTING=OFF                                 \
      -DCMAKE_EXPORT_COMPILE_COMMANDS=ON                  \
      ${CXXSTD:+-DCMAKE_CXX_STANDARD=$CXXSTD}             \
      ${XERCESC_ROOT:+-DXercesC_ROOT=$XERCESC_ROOT}

cmake --build . -- ${JOBS+-j $JOBS} install

# Modulefile
MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
alibuild-generate-module --lib > $MODULEFILE
cat >> "$MODULEFILE" <<EOF2
# extra environment
set VECGEOM_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
setenv VECGEOM_ROOT \$VECGEOM_ROOT
EOF2
