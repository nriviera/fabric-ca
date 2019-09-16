#!/bin/bash
export PATH=$PATH:/Users/cornoro/projects/hyperledger/fabric-samples/bin
BASE_FOLDER=../resources/crypto-config/peerOrganizations

function orgStruct() {
    mkdir -p $1/$2/ca
    mkdir -p $1/$2/msp
    mkdir -p $1/$2/peers
    mkdir -p $1/$2/tlsca
    mkdir -p $1/$2/users
}

function tlsCa() {
    cp /tmp/hyperledger/tls-ca/crypto/tls-ca-cert.pem $1/$2/tlsca
}

rm -rf ../resources/crypto-config
orgStruct $BASE_FOLDER org0
tlsCa $BASE_FOLDER org0
