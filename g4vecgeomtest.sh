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


# for p in geantino chargedgeantino e-; do
for p in e-; do
for s in 10; do
for f in 1; do

export G4VECGEOMTESTNSENSORS=${s}
export G4VECGEOMTESTNEVENTS=100
export G4VECGEOMTESTPDG=${p}
export G4VECGEOMTESTFIELD=${f}

cp ${SOURCEDIR}/bench.g4.in .
cp ${SOURCEDIR}/*.sh .


# run valgrind callgrind comparison
./run_comparison.sh

# run memcheck
./run_memcheck.sh

# run logger comparison
./run_comparison_withlogging.sh

# copy everything somewhere visible (eos??)
DATESTRING=`date +"%y:%m:%d-%H:%M"`
TESTDIR="G4VECGEOMTEST_NORMAL_PDG${G4VECGEOMTESTPDG}_NEVENTS${G4VECGEOMTESTNEVENTS}_NSEN${G4VECGEOMTESTNSENSORS}_FIELD${G4VECGEOMTESTFIELD}_${DATESTRING}"

mkdir ~/${TESTDIR}
mv * ~/${TESTDIR}

done
done
done
