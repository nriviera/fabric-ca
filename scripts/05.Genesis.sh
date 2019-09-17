#!/bin/bash
export PATH=$PATH:/Users/cornoro/projects/hyperledger/fabric-samples/bin
export CHANNEL_ID=mychannel

rm -rf /tmp/hyperledger/genesis
mkdir -p /tmp/hyperledger/genesis/org0/msp/admincerts
mkdir -p /tmp/hyperledger/genesis/org0/msp/cacerts
mkdir -p /tmp/hyperledger/genesis/org0/msp/tlscacerts
mkdir -p /tmp/hyperledger/genesis/org1/msp/admincerts
mkdir -p /tmp/hyperledger/genesis/org1/msp/cacerts
mkdir -p /tmp/hyperledger/genesis/org1/msp/tlscacerts
mkdir -p /tmp/hyperledger/genesis/org2/msp/admincerts
mkdir -p /tmp/hyperledger/genesis/org2/msp/cacerts
mkdir -p /tmp/hyperledger/genesis/org2/msp/tlscacerts

fabric-ca-client getcainfo --tls.certfiles /tmp/hyperledger/org0/ca/admin/msp/cacerts/0-0-0-0-7053.pem -M /tmp/hyperledger/genesis/org0/msp -u https://0.0.0.0:7053
fabric-ca-client getcainfo --tls.certfiles /tmp/hyperledger/org1/ca/admin/msp/cacerts/0-0-0-0-7054.pem -M /tmp/hyperledger/genesis/org1/msp -u https://0.0.0.0:7054
fabric-ca-client getcainfo --tls.certfiles /tmp/hyperledger/org2/ca/admin/msp/cacerts/0-0-0-0-7055.pem -M /tmp/hyperledger/genesis/org2/msp -u https://0.0.0.0:7055

ln -s /tmp/hyperledger/genesis/org0/msp/cacerts/0-0-0-0-7053.pem /tmp/hyperledger/genesis/org0/msp/cacerts/org0-ca-cert.pem
ln -s /tmp/hyperledger/genesis/org1/msp/cacerts/0-0-0-0-7054.pem /tmp/hyperledger/genesis/org1/msp/cacerts/org1-ca-cert.pem
ln -s /tmp/hyperledger/genesis/org2/msp/cacerts/0-0-0-0-7055.pem /tmp/hyperledger/genesis/org2/msp/cacerts/org2-ca-cert.pem
cp /tmp/hyperledger/tls-ca/crypto/tls-ca-cert.pem /tmp/hyperledger/genesis/org0/msp/tlscacerts
cp /tmp/hyperledger/tls-ca/crypto/tls-ca-cert.pem /tmp/hyperledger/genesis/org1/msp/tlscacerts
cp /tmp/hyperledger/tls-ca/crypto/tls-ca-cert.pem /tmp/hyperledger/genesis/org2/msp/tlscacerts
cp /tmp/hyperledger/org0/admin/msp/signcerts/cert.pem /tmp/hyperledger/genesis/org0/msp/admincerts/admin-org0-cert.pem
cp /tmp/hyperledger/org1/admin/msp/signcerts/cert.pem /tmp/hyperledger/genesis/org1/msp/admincerts/admin-org1-cert.pem
cp /tmp/hyperledger/org2/admin/msp/signcerts/cert.pem /tmp/hyperledger/genesis/org2/msp/admincerts/admin-org2-cert.pem
rm -rf /tmp/hyperledger/genesis/org0/msp/keystore/
rm -rf /tmp/hyperledger/genesis/org1/msp/keystore/
rm -rf /tmp/hyperledger/genesis/org2/msp/keystore/
rm -rf /tmp/hyperledger/genesis/org0/msp/signcerts/
rm -rf /tmp/hyperledger/genesis/org1/msp/signcerts/
rm -rf /tmp/hyperledger/genesis/org2/msp/signcerts/

configtxgen -profile OrgsOrdererGenesis -outputBlock /tmp/hyperledger/org0/orderer/genesis.block
configtxgen -profile OrgsChannel -outputCreateChannelTx /tmp/hyperledger/org0/orderer/channel.tx -channelID $CHANNEL_ID