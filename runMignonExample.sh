#!/bin/bash

# prepare test data
echo "MIGNON: Preparing test data..."
curlImage="tutum/curl:trusty"
docker pull ${curlImage}
docker run -v ${PWD}:${PWD} -w ${PWD} ${curlImage} bash prepareTestData.sh

# validate input
echo "MIGNON: Validating input JSON..."
java -jar ${PWD}/mignon_test_data/womtool-47.jar validate wdl/MIGNON.wdl -i test_hisat2_vc.json
java -jar ${PWD}/mignon_test_data/womtool-47.jar validate wdl/MIGNON.wdl -i test_star.json
java -jar ${PWD}/mignon_test_data/womtool-47.jar validate wdl/MIGNON.wdl -i test_salmon.json

# perform dry run
echo "MIGNON: Performing dry run of the workflow..."
java -Dconfig.file=${PWD}/configs/LocalWithDocker.conf -jar ${PWD}/mignon_test_data/cromwell-47.jar run wdl/MIGNON.wdl -i test_hisat2_vc.json > hisat2_vc.log
java -Dconfig.file=${PWD}/configs/LocalWithDocker.conf -jar ${PWD}/mignon_test_data/cromwell-47.jar run wdl/MIGNON.wdl -i test_star.json > star.log
java -Dconfig.file=${PWD}/configs/LocalWithDocker.conf -jar ${PWD}/mignon_test_data/cromwell-47.jar run wdl/MIGNON.wdl -i test_salmon.json > salmon.log