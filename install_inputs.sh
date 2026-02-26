#! /bin/bash

set -x

mkdir website
cd website

# grab the archive file for all inputs
wget --no-check-certificate --progress=dot:mega https://mcc.lip6.fr/2025/archives/INPUTS-2025.tar.gz
tar xzf INPUTS-2025.tar.gz
# cleanup
rm -f INPUTS-2025.tar.gz

mv INPUTS-2025 INPUTS

# remove strange MacOS specific stuff 'LIBARCHIVE.xattr.com.apple.quarantine'
echo "Patching tgz archives"
set +x
cd INPUTS
for i in *.tgz ;
do
	tar xzf $i
	model=$(echo $i | sed 's/.tgz//g')
#	echo "Treating : $model"
	rm $i
	tar czf $i $model/
	rm -rf $model/
done

# unfortunately, these two models are over 100MB compressed, GH pages does not support such large files without paying.
rm StigmergyCommit-PT-11b.tgz TokenRing-PT-050.tgz

cd ..
set -x

if [ ! -f raw-result-analysis.csv ] 
then
	# grab the raw results file from MCC website
	wget --no-check-certificate --progress=dot:mega https://mcc.lip6.fr/2025/archives/raw-result-analysis.csv.tar.gz
	tar xzf raw-result-analysis.csv.tar.gz
fi

# create oracle files
mkdir oracle
# all results available
cat raw-result-analysis.csv | grep -v StateSpace | grep -v UpperBound | cut -d ',' -f2,3,16 | sed 's/\s//g' | sort | uniq | ../csv_to_control.pl
# UpperBounds => do not remove whitespace
cat raw-result-analysis.csv | grep UpperBound | cut -d ',' -f2,3,16 | sort | uniq | ../csv_to_control.pl

 
# Patching bad consensus
# None detected in 2025 so far.

#sed -i -e "s/CryptoMiner-COL-D03N000-UpperBounds-11 0/CryptoMiner-COL-D03N000-UpperBounds-11 +inf/" CryptoMiner-COL-D03N000-UB.out
#sed -i -e "s/PolyORBLF-PT-S02J06T10-UpperBounds-13 9/PolyORBLF-PT-S02J06T10-UpperBounds-13 2/" PolyORBLF-PT-S02J06T10-UB.out
# sed -i -e "s/QuasiLiveness TRUE/QuasiLiveness FALSE/" SieveSingleMsgMbox-PT-d1m06-QL.out
# sed -i -e "s/StigmergyCommit-PT-11a-ReachabilityCardinality-06 TRUE/StigmergyCommit-PT-11a-ReachabilityCardinality-06 FALSE/" StigmergyCommit-PT-11a-RC.out

mv *.out oracle/

#rm -f raw-result-analysis.csv*

cd oracle
tar xzf ../../oracleSS.tar.gz
cd ..
tar czf oracle.tar.gz  oracle/
rm -rf oracle/

tree -H "." > index.html

cd ..
