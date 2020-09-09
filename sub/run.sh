#!/bin/bash
echo 'Subscribing to topic test/test'
set -e
mosquitto_sub -v -h broker -p ${SUB_PORT} -t 'test/test' --id 'client2' --cert /certs/client2.crt --key /certs/client2.key --cafile /certs/serverca.crt --insecure 
