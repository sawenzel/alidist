package: TGeo2VecGeom
version: "%(tag_basename)s"
tag: v0.1.2
source: https://gitlab.cern.ch/VecGeom/tgeo2vecgeom.git
requires:
  - "GCC-Toolchain:(?!osx)"
  - VecGeom
  - ROOT
build_requires:
  - CMake
  - ninja
  - alibuild-recipe-tools
---
#!/bin/bash -e

# A CUDA-enabled VecGeom makes the GPU copy interface of VUnplacedVolume pure virtual;
# give UnplacedRootVolume the same stubs PlacedRootVolume already has. Patched in a copy.
rsync -a --exclude .git "$SOURCEDIR/" ./src/
patch -p1 -d ./src <<'EOP'
diff --git a/include/UnplacedRootVolume.h b/include/UnplacedRootVolume.h
index 259cf9e..0ee50f9 100644
--- a/include/UnplacedRootVolume.h
+++ b/include/UnplacedRootVolume.h
@@ -95,6 +95,22 @@ private:
                                            const TranslationCode trans_code, const RotationCode rot_code,
 #endif
                                            VPlacedVolume *const placement = NULL) const override;
+
+#ifdef VECGEOM_CUDA_INTERFACE
+public:
+  // A ROOT shape has no device implementation; the stubs only satisfy a CUDA-enabled VecGeom.
+  size_t DeviceSizeOf() const override { return 0; }
+  DevicePtr<cuda::VUnplacedVolume> CopyToGpu() const override
+  {
+    assert(0 && "Attempted to copy unsupported ROOT volume to GPU.");
+    return DevicePtr<cuda::VUnplacedVolume>(nullptr);
+  }
+  DevicePtr<cuda::VUnplacedVolume> CopyToGpu(DevicePtr<cuda::VUnplacedVolume> const /* gpu_ptr */) const override
+  {
+    assert(0 && "Attempted to copy unsupported ROOT volume to GPU.");
+    return DevicePtr<cuda::VUnplacedVolume>(nullptr);
+  }
+#endif
 };
 
 } // End namespace tgeo2vecgeom
EOP

cmake ./src -DCMAKE_INSTALL_PREFIX=$INSTALLROOT          \
      -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE:-RelWithDebInfo} \
      -DCMAKE_PREFIX_PATH="$VECGEOM_ROOT;$ROOT_ROOT"       \
      -DCMAKE_INSTALL_LIBDIR=lib                           \
      -DTGEO2VECGEOM_BUILD_TESTS=OFF                       \
      -GNinja

cmake --build . -- ${JOBS+-j $JOBS} install

# aliBuild only relocates references to our own INSTALLROOT, so a hardcoded dependency
# path breaks every consumer that gets us from the build cache. Skipped in devel mode.
if [ "${INSTALLROOT#"$WORK_DIR/$ARCHITECTURE/"}" = "$INSTALLROOT" ] &&
   grep -I -R -l -F "$WORK_DIR/$ARCHITECTURE/" "$INSTALLROOT"; then
  echo "ERROR: the files above hardcode a dependency path" >&2
  exit 1
fi

# Modulefile
MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
alibuild-generate-module --lib --cmake > $MODULEFILE
cat >> "$MODULEFILE" <<EOF
# extra environment
set TGEO2VECGEOM_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
setenv TGEO2VECGEOM_ROOT \$TGEO2VECGEOM_ROOT
EOF
