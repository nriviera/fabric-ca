#!/bin/bash
export PATH=$PATH:/Users/cornoro/projects/hyperledger/fabric-samples/bin


echo -e "\nENROLL PEER2"
mkdir -p /tmp/hyperledger/org2/peer2/assets/ca
cp /tmp/hyperledger/org2/ca/crypto/ca-cert.pem /tmp/hyperledger/org2/peer2/assets/ca/org2-ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/org2/peer2
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/org2/peer2/assets/ca/org2-ca-cert.pem
fabric-ca-client enroll -d -u https://peer2-org2:peer2PW@0.0.0.0:7055
mkdir /tmp/hyperledger/org2/peer2/assets/tls-ca
cp /tmp/hyperledger/tls-ca/crypto/tls-ca-cert.pem /tmp/hyperledger/org2/peer2/assets/tls-ca/
export FABRIC_CA_CLIENT_MSPDIR=tls-msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/org2/peer2/assets/tls-ca/tls-ca-cert.pem
fabric-ca-client enroll -d -u https://peer2-org2:peer2PW@0.0.0.0:7052 --enrollment.profile tls --csr.hosts peer2-org2
f=`ls /tmp/hyperledger/org2/peer2/tls-msp/keystore/`
ln -s /tmp/hyperledger/org2/peer2/tls-msp/keystore/$f /tmp/hyperledger/org2/peer2/tls-msp/keystore/key.pem 
