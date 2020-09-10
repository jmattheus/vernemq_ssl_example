# VerneMQ SSL Listener Example
## Download and Build
### Download source
`git clone git@github.com:jmattheus/vernemq_ssl_example.git && cd vernemq_ssl_example`
### Generate Certificates
`./casetup.sh`
### Build with Docker Compose
`docker-compose build`

## Start the broker
In one terminal, start the VerneMQ broker
`docker-compose up broker`

The broker uses the vernemq.conf file in the broker/ directory. This config file is supposed to enable an SSL listener on the broker service IP address at port 8883. 

## Start subscriber client
In another terminal, start a client that subscribes to the test/test topic
`docker-compose up sub`

The subscriber client uses mosquitto_sub to connect to the broker using a client certificate generated from the broker CA certificate.

## Start publisher client
In another terminal, start a client that publishes to the test/test topic every 2 seconds
`docker-compose up pub`

The publisher client uses mosquitto_pub to connect to the broker using a client certificate generated from the broker CA certificate. The client certificate and keys are the same as used for testing VerneMQ. Since the publisher reuses the subscriber certificate, the broker configuration contains the line `allow_multiple_sessions = on`

## Test with MQTT
By default, this example configures the pub and sub clients to connect on port 8883. You can test MQTT by changing environment variables in the docker-compose.yml file. Specifically, change the SUB_PORT and PUB_PORT values to 1883 to use MQTT instead.

# Explanation of the Certs and Config
## Certificate Authority
A Certificate Authority (CA) in its simplest form is a certificate that is used to sign other certificates. A system can trust a CA and in doing so implicitly trusts certificates signed by the CA. As it's used in this example, a CA consists of a public portion, `ca.crt`, and a private key, `ca.key`. The public portion needs to be trusted by a system that intends to use certificates issued by the CA. The private key is only needed to sign/issue child certificates.

In this example, `casetup.sh` creates multiple Certificate Authorities in an effort to make it clear which systems need to trust which certs.  

## Broker Certificate
The broker certificate is used to set up a basic SSL connection to the broker. In this example, we create a CA called `serverca.crt`. We then create a certificate and key for the broker named `server.crt` which is signed by `serverca.crt`/`serverca.key` and has a corresponding private key `server.key`.

The certificate and the key are specified in the `vernemq.conf` file:
```
listener.ssl.default.certfile = /certs/server.crt
listener.ssl.default.keyfile = /certs/server.key
```

A client connecting to the broker must trust the broker CA for the SSL connection to work. In this example, we enable that trust by adding `--cafile /certs/serverca.crt` to the mosquitto client calls.  The trust could also be achieved by installing the CA cert as a trusted authority onto the machine running the client.

## Client Certificate
The client certificate is used to authenticate the client to the broker and must be issued by a CA the broker trusts. In this example, we have multiple client certs and corresponding keys issued by multiple CAs. 

1. `client1.crt`/`client1.key` issued by `client1ca.crt`
1. `client2.crt`/`client2.key` issued by `client2ca.crt`
1. `client3.crt`/`client3.key` issued by `sharedca.crt`
1. `client4.crt`/`client4.key` issued by `sharedca.crt`

The client uses the cert and key when communicating with the broker.  In this example we pass through the mosquitto client with `--cert /certs/client1.crt --key /certs/client1.key`

The server must be able to trust all 3 CAs which could issue certs for use by authorized clients.  This trust is achieved by concatenating the public CA certs together into a single file, `allclientca.crt`, and referencing it in the `vernemq.conf` file:

```
listener.ssl.default.cafile = /certs/allclientca.crt
```
