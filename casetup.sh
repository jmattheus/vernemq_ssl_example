#!/bin/bash

create_client() {
    if [ ! -f $2.key ]; then
        echo "Creating ca $2"
        openssl req \
            -new \
            -newkey rsa:2048 \
            -days 365 \
            -nodes \
            -x509 \
            -subj "/C=/ST=/L=/O=Dis/CN=$2" \
            -keyout certs/$2.key \
            -out certs/$2.crt
    fi
    openssl req \
        -new \
        -newkey rsa:2048 \
        -days 365 \
        -nodes \
        -subj "/C=/ST=/L=/O=Dis/CN=$1" \
        -keyout certs/$1.key \
        -out certs/$1.csr
    openssl x509 -req -in certs/$1.csr -CA certs/$2.crt -CAkey certs/$2.key -CAcreateserial -out certs/$1.crt -days 360
    echo 'pass' | openssl pkcs12 -export -out certs/$1.pfx -inkey certs/$1.key -in certs/$1.crt -passout stdin
}
mkdir -p certs
create_client server serverca pass
create_client client1 clientca1 pass
create_client client2 clientca2 pass
create_client linqpad1 linqpadca pass
create_client linqpad2 linqpadca pass

cp certs/clientca1.crt certs/allclientca.crt
cat certs/clientca2.crt >> certs/allclientca.crt
cat certs/linqpadca.crt >> certs/allclientca.crt