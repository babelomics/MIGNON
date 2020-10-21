#!/bin/bash


if [ ! -d "$PWD/mignon_test_data" ]; then
    fileid="1iH2UUF-awGPKYgixP9_5mApMpqGFDiBU";
    filename="$PWD/mignon_test_data.tar.gz";
    curl -c ./cookie -s -L "https://drive.google.com/uc?export=download&id=${fileid}" > /dev/null
    curl -Lb ./cookie "https://drive.google.com/uc?export=download&confirm=`awk '/download/ {print $NF}' ./cookie`&id=${fileid}" -o ${filename}
    mkdir -p ${filename/.tar.gz/}
    tar -xzvf ${filename} --directory ${filename/.tar.gz/}
fi
    
sed -i "s#flagForPwd#${PWD}#g" tests/test_input.json