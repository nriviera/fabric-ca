#!/bin/bash
export PATH=$PATH:/Users/cornoro/projects/hyperledger/fabric-samples/bin


echo -e "\nENROLL ORG2 User"
export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/org2/user
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/org2/peer1/assets/ca/org2-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp
fabric-ca-client enroll -d -u https://user-org2:org2UserPW@0.0.0.0:7055
