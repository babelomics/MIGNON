#!/bin/bash
if [ ! -d "$PWD/mignon_test_data" ]; then
    fileid="1FuQre-nOuZHlQ_N-U5XE26WLj-ou0lXz";
    filename="$PWD/mignon_test_data.tar.gz";
    curl -c ./cookie -s -L "https://drive.google.com/uc?export=download&id=${fileid}" > /dev/null
    curl -Lb ./cookie "https://drive.google.com/uc?export=download&confirm=`awk '/download/ {print $NF}' ./cookie`&id=${fileid}" -o ${filename}
    tar -xzvf ${filename}
    chmod 777 -R $PWD/mignon_test_data/
    echo "MIGNON test data ---- OK"
else 
    echo "A directory with MIGNON test data already exists!"
fi

# prepare test json
sed "s#flagForPwd#${PWD}#g" tests/test_hisat2_vc.json > test_hisat2_vc.json
sed "s#flagForPwd#${PWD}#g" tests/test_star.json > test_star.json
sed "s#flagForPwd#${PWD}#g" tests/test_salmon.json > test_salmon.json