#!/bin/bash
export PATH=$PATH:/Users/cornoro/projects/hyperledger/fabric-samples/bin
BASE_PEER=../resources/crypto-config/peerOrganizations
BASE_ORDERER=../resources/crypto-config/ordererOrganizations

function orgStruct() {
    mkdir -p $1/$2/ca
    mkdir -p $1/$2/msp
    mkdir -p $1/$2/peers
    mkdir -p $1/$2/tlsca
    mkdir -p $1/$2/users
}

function tlsCA() {
    cp /tmp/hyperledger/tls-ca/crypto/tls-ca-cert.pem $1/$2/tlsca
    cp /tmp/hyperledger/tls-ca/crypto/msp/keystore/*_sk $1/$2/tlsca
}

function orgCA {
    cp /tmp/hyperledger/$2/ca/crypto/ca-cert.pem $1/$2/ca/ca-$2-cert.pem
}

rm -rf ../resources/crypto-config
orgStruct $BASE_ORDERER org0
orgStruct $BASE_PEER org1
tlsCA $BASE_ORDERER org0
tlsCA $BASE_PEER org1
orgCA $BASE_PEER org1