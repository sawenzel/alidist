package: xercesc
version: Xerces-C_3_2_2
tag: Xerces-C_3_2_2
source: https://github.com/apache/xerces-c
build_requires:
  - CMake
prefer_system: ".*"
prefer_system_check: |
  pkg-config --atleast-version=3.2.0 xerces-c 2>&1 && printf "#include \"<xercesc/util/PlatformUtils.hpp>\"\nint main(){}" | c++ -xc - -o /dev/null
---

cmake $SOURCEDIR                                         \
      -DCMAKE_INSTALL_PREFIX=$INSTALLROOT                    

make ${JOBS:+-j $JOBS}
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
module load BASE/1.0 ${BOOST_VERSION:+boost/$BOOST_VERSION-$BOOST_REVISION}
# Our environment
setenv XERCESC_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path LD_LIBRARY_PATH \$::env(XERCESC_ROOT)/lib
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH \$::env(ARROW_ROOT)/lib")
EoF
