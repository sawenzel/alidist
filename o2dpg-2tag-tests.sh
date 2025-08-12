package: O2DPG-2tag-tests
version: "1.0"
build_requires:
  - xjalienfs
  - O2DPG
force_rebuild: true
---
#!/bin/bash

set -x

# This recipe performs a compatibility check of a MC O2PDPSuite release
# against a given set of async-reco O2PDPSuite releases for the 2tag MC approach 
# in O2DPG.
#
# The main purpose of this script is an easy integration of these tests into
# the ALICE Jenkins infrastructure (which is using alibuild extensively).
#
# The recipe needs to be given a CVMFS-released software tag of O2DPGSuite via env variable
# MC_2STAGE_TEST_TAG. This could come for instance from a Jenkins parameterized project.

if [ -z ${MC_2STAGE_TEST_TAG} ]; then
  echo "This recipe needs to be given a software tag to test."
  echo "example: export MC_2STAGE_TEST_TAG=O2PDPSuite::MC-prod-2025-v9-1"
fi

ALIEN_USER=$(alien.py whoami)
echo "ALIEN_USER=${ALIEN_USER}"
export ALIEN_USER=${ALIEN_USER}

# check that we have an alien token 
${XJALIENFS_ROOT}/bin/alien-token-info
if [[ ! $? -eq 0 ]]; then
  echo "This test needs an alien token"
  exit 1
fi

#git clone https://github.com/AliceO2Group/O2DPG O2DPG
#export O2DPG_ROOT=${PWD}/O2DPG

# With this we simply call the testing scripts of O2DPG for this purpose:
rsync -av ${O2DPG_ROOT}/MC/run/ANCHOR/tests/ ./
./test_looper.sh ${MC_2STAGE_TEST_TAG}

