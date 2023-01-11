package: HEPscore-CCDB
version: v0.1.5-coredigireco-snapshot-compatible-20221215
build_requires:
  - xjalienfs
  - alibuild-recipe-tools
---
#!/bin/bash

# A build recipe producing a CCDB snapshot for the HEPscore benchmark.
# - publish CCDB snapshot on CVFMS via alibuild/jenkins
# - allow execution of benchmark without ALIEN token/network

export ROOT_INCLUDE_PATH=${ROOT_INCLUDE_PATH}:${PYTHIA_ROOT}/include
# this is to access tokens and alien
export PYTHONPATH=${PYTHONPATH}:${XJALIENFS_ROOT}/lib/python/site-packages
export X509_USER_CERT=/etc/grid-security/hostcert.pem 
export X509_USER_KEY=/etc/grid-security/hostkey.pem 
export X509_CERT_DIR=/etc/grid-security/certificates
export PATH=${PATH}:${XJALIENFS_ROOT}/bin

env | tr ":" "\n" > runenv.log

# check if we can access alien
# alien.py ls /alice/cern.ch/user/a/aliperf/
alien-token-info || true

# get the precreated snapshot
# (containing all input files for benchmark, including CCDB snapshot)
alien.py cp /alice/cern.ch/user/a/aliperf/HEPscore/hepscore_checkpoint_20221215.tar.gz file:./hepscore_checkpoint.tar.gz

# install artefacts
rsync -a --delete hepscore_checkpoint.tar.gz $INSTALLROOT
# mkdir -p $INSTALLROOT/data && rsync -a --delete matbud.root $INSTALLROOT/data

# Modulefile
mkdir -p $INSTALLROOT/etc/modulefiles
alibuild-generate-module > $INSTALLROOT/etc/modulefiles/$PKGNAME

cat << EOF >> $INSTALLROOT/etc/modulefiles/$PKGNAME
set HEPSCORE_CCDB_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
setenv HEPSCORE_CCDB_ROOT \$HEPSCORE_CCDB_ROOT
setenv HEPSCORE_CCDB_VERSION $PKGVERSION
EOF
