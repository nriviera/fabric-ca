#!/bin/bash
export PATH=$PATH:/Users/cornoro/projects/hyperledger/fabric-samples/bin


echo -e "\nENROLL PEER1"
mkdir -p /tmp/hyperledger/org1/peer1/assets/ca
cp /tmp/hyperledger/org1/ca/crypto/ca-cert.pem /tmp/hyperledger/org1/peer1/assets/ca/org1-ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/org1/peer1
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/org1/peer1/assets/ca/org1-ca-cert.pem
fabric-ca-client enroll -d -u https://peer1-org1:peer1PW@0.0.0.0:7054
mkdir /tmp/hyperledger/org1/peer1/assets/tls-ca
cp /tmp/hyperledger/tls-ca/crypto/tls-ca-cert.pem /tmp/hyperledger/org1/peer1/assets/tls-ca/
export FABRIC_CA_CLIENT_MSPDIR=tls-msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/org1/peer1/assets/tls-ca/tls-ca-cert.pem
fabric-ca-client enroll -d -u https://peer1-org1:peer1PW@0.0.0.0:7052 --enrollment.profile tls --csr.hosts peer1-org1
f=`ls /tmp/hyperledger/org1/peer1/tls-msp/keystore/`
ln -s /tmp/hyperledger/org1/peer1/tls-msp/keystore/$f /tmp/hyperledger/org1/peer1/tls-msp/keystore/key.pem
