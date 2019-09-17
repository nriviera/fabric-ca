#!/bin/bash
export PATH=$PATH:/Users/cornoro/projects/hyperledger/fabric-samples/bin

echo -e "\nENROLL ORDERER"
mkdir -p /tmp/hyperledger/org0/orderer/assets/ca/
cp /tmp/hyperledger/org0/ca/crypto/ca-cert.pem /tmp/hyperledger/org0/orderer/assets/ca/org0-ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/org0/orderer
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/org0/orderer/assets/ca/org0-ca-cert.pem
fabric-ca-client enroll -d -u https://orderer1-org0:ordererPW@0.0.0.0:7053
mkdir -p /tmp/hyperledger/org0/orderer/assets/tls-ca/
cp /tmp/hyperledger/tls-ca/crypto/tls-ca-cert.pem /tmp/hyperledger/org0/orderer/assets/tls-ca/tls-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=tls-msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/org0/orderer/assets/tls-ca/tls-ca-cert.pem
fabric-ca-client enroll -d -u https://orderer1-org0:ordererPW@0.0.0.0:7052 --enrollment.profile tls --csr.hosts orderer1-org0
f=`ls /tmp/hyperledger/org0/orderer/tls-msp/keystore/`
ln -s /tmp/hyperledger/org0/orderer/tls-msp/keystore/$f /tmp/hyperledger/org0/orderer/tls-msp/keystore/key.pem 
