#!/bin/bash
if [ ! -d "$HOME/misc_cache/mignon_test_data" ]; then
    fileid="1iH2UUF-awGPKYgixP9_5mApMpqGFDiBU";
    filename="$HOME/misc_cache/mignon_test_data.tar.gz";
    curl -c ./cookie -s -L "https://drive.google.com/uc?export=download&id=${fileid}" > /dev/null
    curl -Lb ./cookie "https://drive.google.com/uc?export=download&confirm=`awk '/download/ {print $NF}' ./cookie`&id=${fileid}" -o ${filename}
    tar -xzvf ${filename}
fi

# prepare test json
sed -i "s#flagForPwd#${PWD}#g" tests/test_input.json

#java -Dconfig.file=configs/LocalWithDocker.conf -jar $HOME/misc_cache/mignon_test_data/mignon_test_data/cromwell-47.jar run wdl/MIGNON.wdl -i tests/test_input.json