#!/bin/bash

# prepare test data
echo "MIGNON: Preparing test data..."
curlImage="tutum/curl:trusty"
docker pull ${curlImage}
docker run -v ${PWD}:${PWD} -w ${PWD} ${curlImage} bash tests/prepareTestData.sh

# validate input
echo "MIGNON: Validating input JSON..."
java -jar ${PWD}/mignon_test_data/womtool-47.jar validate wdl/MIGNON.wdl -i test_hisat2_vc.json
java -jar ${PWD}/mignon_test_data/womtool-47.jar validate wdl/MIGNON.wdl -i test_star.json
java -jar ${PWD}/mignon_test_data/womtool-47.jar validate wdl/MIGNON.wdl -i test_salmon.json

# perform dry run
echo "MIGNON: Performing dry run of the workflow..."
java -Dconfig.file=${PWD}/tests/travisWithDocker.conf -jar ${PWD}/mignon_test_data/cromwell-47.jar run wdl/MIGNON.wdl -i test_hisat2_vc.json
java -Dconfig.file=${PWD}/tests/travisWithDocker.conf -jar ${PWD}/mignon_test_data/cromwell-47.jar run wdl/MIGNON.wdl -i test_star.json
java -Dconfig.file=${PWD}/tests/travisWithDocker.conf -jar ${PWD}/mignon_test_data/cromwell-47.jar run wdl/MIGNON.wdl -i test_salmon.json
java -Dconfig.file=${PWD}/tests/travisWithDocker.conf -jar ${PWD}/mignon_test_data/cromwell-47.jar run wdl/MIGNON_htseq.wdl -i test_star.json

# create and move all the outputs to the new directory
mkdir -p dry_run
mv -f test_hisat2_vc.json test_star.json test_salmon.json cromwell-execution cromwell-workflow-logs dry_run