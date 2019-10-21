package: g4vecgeomtest
version: "1.0"
tag: master
source: https://swenzel@bitbucket.org/swenzel/g4vecgeom_test.git
requires:
  - g4vecgeomspec
  - g4navigatorlogger
force_rebuild: 1
---
#!/bin/bash -e
MODE="NORMAL"
if [ -z ${G4VECGEOMSPEC_ROOT+x} ]; then
    echo "using normal mode"
else
    MODE="SPEC"
    echo "using specialized moded"
fi

# for p in geantino chargedgeantino e-; do
for p in e-; do
    # for s in 2 6 10 15; do
for s in 2 6 8 10; do
for f in 1; do

export G4VECGEOMTESTNSENSORS=${s}
export G4VECGEOMTESTNEVENTS=40
export G4VECGEOMTESTPDG=${p}
export G4VECGEOMTESTFIELD=${f}
export G4VECGEOMTESTREP=5          # number of repetitions
export G4VECGEOMTESTSHAPETYPE=1    # shape of sensors (by default tube as defined in makeComplexGeom.C)
export G4VECGEOMTESTDENSE=true

# see if we can find voxel cashes corresponding to this geometry
cp ~/VecGeomVoxelCache/*.root_TYPE${G4VECGEOMTESTSHAPETYPE} . || :
rename 's/_TYPE.$//' *.root_TYPE*

cp ${SOURCEDIR}/bench.g4.in .
cp ${SOURCEDIR}/*.sh .

# run valgrind callgrind comparison
./run_speed_comparison.sh

# ./run_comparison.sh

# run memcheck
#./run_memcheck.sh

# run logger comparison
# ./run_comparison_withlogging.sh

# copy everything somewhere visible (eos??)
DATESTRING=`date +"%y:%m:%d-%H:%M"`
TESTDIR="G4VECGEOMTESTNEWREALDENSE_${MODE}_PDG${G4VECGEOMTESTPDG}_NEVENTS${G4VECGEOMTESTNEVENTS}_NSEN${G4VECGEOMTESTNSENSORS}_FIELD${G4VECGEOMTESTFIELD}_${DATESTRING}"

# update the voxel cashes if they don't exist
find ./ -name "DENSE*.root" -exec cp -n {} ~/VecGeomVoxelCache/{}_TYPE${G4VECGEOMTESTSHAPETYPE} ';'

mkdir ~/${TESTDIR}
mv * ~/${TESTDIR}

done
done
done
