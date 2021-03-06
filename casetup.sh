#!/bin/bash

create_client() {
    if [ ! -f certs/$2.key ]; then
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
rm certs/*
create_client server serverca pass
create_client client1 clientca1 pass
create_client client2 clientca2 pass
create_client client3 sharedca pass
create_client client4 sharedca pass

cp certs/clientca1.crt certs/allclientca.crt
cat certs/clientca2.crt >> certs/allclientca.crt
cat certs/sharedca.crt >> certs/allclientca.crt