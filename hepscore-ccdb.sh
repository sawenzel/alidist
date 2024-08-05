package: HEPscore-CCDB
version: alice3-lut-v0.0.2
build_requires:
  - xjalienfs
  - alibuild-recipe-tools
---
#!/bin/bash

# A build recipe publishing data files via alibuild + ali-bot publish

export ROOT_INCLUDE_PATH=${ROOT_INCLUDE_PATH}:${PYTHIA_ROOT}/include
# this is to access tokens and alien
export PYTHONPATH=${PYTHONPATH}:${XJALIENFS_ROOT}/lib/python/site-packages
export PATH=${PATH}:${XJALIENFS_ROOT}/bin

echo "Trying token"
#alien-token-info
RC=1

if [ "${RC}" != "0" ]; then
 # this is for JENKINS usage (to pick up GRID certificate)
 export X509_USER_CERT=/etc/grid-security/hostcert.pem 
 export X509_USER_KEY=/etc/grid-security/hostkey.pem 
 export X509_CERT_DIR=/etc/grid-security/certificates
fi

env | tr ":" "\n" > runenv.log

# check if we can access alien
alien-token-info || true

# get the precreated data
alien.py cp /alice/cern.ch/user/d/ddobrigk/LUT/* file:./ALICE3-FASTSIM-LUT

# install artefacts
rsync -a --delete * $INSTALLROOT
echo "Data files  (Delphes lookup tables) for ALICE3 R&D studies" >> $INSTALLROOT/README.txt

# Modulefile --> not needed
mkdir -p $INSTALLROOT/etc/modulefiles
alibuild-generate-module > $INSTALLROOT/etc/modulefiles/$PKGNAME

cat <<EOF >> $INSTALLROOT/etc/modulefiles/$PKGNAME
set ALICE3-DATA_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
setenv ALICE3-DATA_ROOT \$ALICE3-DATA_ROOT
setenv ALICE3-DATA_VERSION $PKGVERSION
EOF

