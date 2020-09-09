#!/bin/bash
while :
do
    echo 'Publishing to test/test'
    mosquitto_pub -h broker -p ${PUB_PORT} -t 'test/test' -m "$("date")" -d --cert /certs/client1.crt --key /certs/client1.key --cafile /certs/serverca.crt --insecure 
    sleep 2s
done
