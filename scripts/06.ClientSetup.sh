#!/bin/bash
export PATH=$PATH:/Users/cornoro/projects/hyperledger/fabric-samples/bin
BASE_PEER=../resources/crypto-config/peerOrganizations
BASE_ORDERER=../resources/crypto-config/ordererOrganizations

# $1 base folder
# $2 org name
function orgStruct() {
    mkdir -p $1/$2/ca
    mkdir -p $1/$2/msp
    mkdir -p $1/$2/peers
    mkdir -p $1/$2/tlsca
    mkdir -p $1/$2/users
}

# $1 base folder
# $2 org name
function tlsCA() {
    cp /tmp/hyperledger/tls-ca/crypto/tls-ca-cert.pem $1/$2/tlsca
    cp /tmp/hyperledger/tls-ca/crypto/msp/keystore/*_sk $1/$2/tlsca
}

# $1 base folder
# $2 org name
function orgCA() {
    cp /tmp/hyperledger/$2/ca/crypto/ca-cert.pem $1/$2/ca/ca-$2-cert.pem
    cp /tmp/hyperledger/$2/ca/admin/msp/signcerts/cert.pem $1/$2/ca/$2-cert.pem
}

# $1 base folder
# $2 org name
function peerMSP() {
    cp -r /tmp/hyperledger/genesis/$2/msp/admincerts $1/$2/msp
    cp -r /tmp/hyperledger/genesis/$2/msp/cacerts $1/$2/msp
    cp -r /tmp/hyperledger/genesis/$2/msp/tlscacerts $1/$2/msp
} 

# $1 base folder
# $2 org name
# $3 peer name
function orgPeer() {
    mkdir -p $1/$2/peers/$3/tls
    cp $1/$2/tlsca/tls-ca-cert.pem $1/$2/peers/$3/tls/ca.crt
    cp /tmp/hyperledger/$2/$3/msp/signcerts/cert.pem $1/$2/peers/$3/tls/server.crt
    cp /tmp/hyperledger/$2/$3/msp/keystore/*_sk $1/$2/peers/$3/tls/server.key
    cp -r /tmp/hyperledger/$2/$3/msp $1/$2/peers/$3
    rm -f $1/$2/peers/$3/msp/Issuer*
    rm -rf $1/$2/peers/$3/msp/user
}

# $1 base folder
# $2 org name
# $3 user name
function orgUser() {
    mkdir -p $1/$2/users/$3-$2@$2/tls
    cp $1/$2/tlsca/tls-ca-cert.pem $1/$2/users/$3-$2@$2/tls/ca.crt
    cp /tmp/hyperledger/$2/$3/msp/signcerts/cert.pem $1/$2/users/$3-$2@$2/tls/server.crt
    cp /tmp/hyperledger/$2/$3/msp/keystore/*_sk $1/$2/users/$3-$2@$2/tls/server.key
    cp -r /tmp/hyperledger/$2/$3/msp $1/$2/users/$3-$2@$2/
    rm -f $1/$2/users/$3-$2@$2/msp/Issuer*
    rm -rf $1/$2/users/$3-$2@$2/msp/user
}

rm -rf ../resources/crypto-config
orgStruct $BASE_ORDERER org0
orgStruct $BASE_PEER org1
tlsCA $BASE_ORDERER org0
tlsCA $BASE_PEER org1
orgCA $BASE_ORDERER org0
orgCA $BASE_PEER org1
peerMSP $BASE_ORDERER org0
peerMSP $BASE_PEER org1
orgPeer $BASE_PEER org1 peer1
orgPeer $BASE_PEER org1 peer2
orgUser $BASE_PEER org1 admin
