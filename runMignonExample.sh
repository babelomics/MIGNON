#!/bin/bash

# prepare test data
echo "MIGNON: Preparing test data..."
ubuntuImage="ubuntu"
curlImage="curlimages/curl"
data_url="https://zenodo.org/record/4279753/files/mignon_test_data.tar.gz?download=1"
dest_file="$PWD/mignon_test_data.tar.gz"
test_hisat_file="tests/hisat2.json"
test_star_file="tests/star.json"
test_salmon_file="tests/salmon.json"

if [ ! -d "$PWD/mignon_test_data" ]; then
    docker run -v ${PWD}:${PWD} -w ${PWD} ${curlImage} curl $data_url > ${dest_file}
    docker run -v ${PWD}:${PWD} -w ${PWD} ${ubuntuImage} tar -xvf ${dest_file} && chmod 777 -R $PWD/mignon_test_data/
    echo "MIGNON test data ---- OK"
else 
    echo "A directory with MIGNON test data already exists!"
fi

# prepare test json
docker run -v ${PWD}:${PWD} -w ${PWD} ${ubuntuImage} sed "s#flagForPwd#${PWD}#g" tests/test_hisat2_vc.json > ${test_hisat_file}
docker run -v ${PWD}:${PWD} -w ${PWD} ${ubuntuImage} sed "s#flagForPwd#${PWD}#g" tests/test_star.json > ${test_star_file}
docker run -v ${PWD}:${PWD} -w ${PWD} ${ubuntuImage} sed "s#flagForPwd#${PWD}#g" tests/test_salmon.json > ${test_salmon_file}

# validate input
echo "MIGNON: Validating input JSON..."
java -jar ${PWD}/mignon_test_data/womtool-47.jar validate wdl/MIGNON.wdl -i ${test_hisat_file}
java -jar ${PWD}/mignon_test_data/womtool-47.jar validate wdl/MIGNON.wdl -i ${test_star_file}
java -jar ${PWD}/mignon_test_data/womtool-47.jar validate wdl/MIGNON.wdl -i ${test_salmon_file}
java -jar ${PWD}/mignon_test_data/womtool-47.jar validate wdl/MIGNON_htseq.wdl -i ${test_star_file}

# perform dry run
echo "MIGNON: Performing dry runs of the workflow..."
java -Dconfig.file=${PWD}/configs/LocalWithDocker.conf -jar ${PWD}/mignon_test_data/cromwell-47.jar run wdl/MIGNON.wdl -i ${test_hisat_file}
java -Dconfig.file=${PWD}/configs/LocalWithDocker.conf -jar ${PWD}/mignon_test_data/cromwell-47.jar run wdl/MIGNON.wdl -i ${test_star_file}
java -Dconfig.file=${PWD}/configs/LocalWithDocker.conf -jar ${PWD}/mignon_test_data/cromwell-47.jar run wdl/MIGNON.wdl -i ${test_salmon_file}
java -Dconfig.file=${PWD}/configs/LocalWithDocker.conf -jar ${PWD}/mignon_test_data/cromwell-47.jar run wdl/MIGNON_htseq.wdl -i ${test_star_file}

# if everything worked as expected, then move all the execution material to dry run and print success message
if [[ $? -eq 0 ]]; then

    docker run -v ${PWD}:${PWD} -w ${PWD} ${ubuntuImage} mv ${test_hisat_file} dry_run/
    mkdir -p dry_run && mv -f ${test_hisat_file} ${test_star_file} ${test_salmon_file} cromwell-executions cromwell-workflow-logs dry_run && chmod 777 -R dry_run/
    echo "MIGNON: Success!! Dry runs completed. You are ready to execute MIGNON.";
fi
