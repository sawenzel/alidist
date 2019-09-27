package: embree
version: "%(tag_basename)s"
tag: v3.6.1
source: https://www.github.com/embree/embree
requires:
  - "GCC-Toolchain:(?!osx)"
build_requires:
  - CMake
---

#!/bin/bash -e
cmake $SOURCEDIR ${CXXSTD:+-DCMAKE_CXX_STANDARD=$CXXSTD}  \
      -DEMBREE_ISPC_SUPPORT=OFF                           \
      -DEMBREE_TASKING_SYSTEM=INTERNAL                    \
      -DCMAKE_INSTALL_PREFIX=$INSTALLROOT                 \
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
module load BASE/1.0
# Our environment
set osname [uname sysname]
setenv EMBREE_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path PATH \$::env(EMBREE_ROOT)/bin
prepend-path LD_LIBRARY_PATH \$::env(EMBREE_ROOT)/lib
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH \$::env(EMBREE_ROOT)/lib")
EoF
