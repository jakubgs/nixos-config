#!/usr/bin/env bash
set -ex

#echo "Generating CA Private Key..."
#openssl genrsa -des3 -out root-ca.key 2048
#echo "Generating CA Certificate..."
#openssl req -x509 -new -nodes -key root-ca.key -sha256 -days 1825 -config root-ca.cnf -out root-ca.pem

# You will be prompted for a passphrase which will be distributed to your user with the certificate.
# Do NOT ever distribute the passphrase set above for your root CA’s private key. Make sure you understand this distinction!
#echo "Generating User Private Key..."
#openssl genrsa -des3 -out user.key 2048
#echo "Generating User Certificate Signing Request..."
#openssl req -new -config user.cnf -key user.key -out user.csr
## Sign with our certificate-signing CA
## This certificate will be valid for one year. Change as per your requirements.
## You can increment the serial if you have to reissue the CERT
#echo "Generating User Certificate..."
#openssl x509 -req -days 365 -in user.csr -CA root-ca.pem -CAkey root-ca.key -set_serial 01 -out user.crt

echo "Generating Server Private Key..."
openssl genrsa -nodes -des3 -out server.key 2048
echo "Generating Server Certificate Signing Request..."
openssl req -new -out server.csr -config server.cnf
echo "Generating Server Certificate..."
openssl x509 -req -nodes -days 365 -in server.csr -CA root-ca.pem -CAkey root-ca.key -set_serial 01 -out server.crt
