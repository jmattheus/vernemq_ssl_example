#!/bin/bash
cp  /certs/server.crt /etc/vernemq/ssl
cp  /certs/allclientca.crt /etc/vernemq/ssl
cp  /certs/server.key /etc/vernemq/ssl

cp /broker/vernemq.conf /etc/vernemq/vernemq.conf.local
start_vernemq
