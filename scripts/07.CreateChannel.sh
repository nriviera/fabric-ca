#!/bin/bash

CHANNEL_ID=mychannel
CORE_ORG1_MSPCONFIGPATH=/tmp/crypto-config/peerOrganizations/org1/users/admin-org1\@org1/msp/
CORE_ORG2_MSPCONFIGPATH=/tmp/crypto-config/peerOrganizations/org2/users/admin-org2\@org2/msp/
ORG1_PEER1_ASSETS=/tmp/hyperledger/org1/peer1/assets
ORG1_PEER2_ASSETS=/tmp/hyperledger/org1/peer2/assets
ORG2_PEER1_ASSETS=/tmp/hyperledger/org2/peer1/assets
ORG2_PEER2_ASSETS=/tmp/hyperledger/org2/peer2/assets
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/org1/peer1/assets/tls-ca/tls-ca-cert.pem
cp /tmp/hyperledger/org0/orderer/channel.tx $ORG1_PEER1_ASSETS/channel.tx
# # Create the channel
docker exec -e "CORE_PEER_MSPCONFIGPATH=${CORE_ORG1_MSPCONFIGPATH}" cli-org1 peer channel create -o orderer1-org0:7050 -c $CHANNEL_ID -f $ORG1_PEER1_ASSETS/channel.tx --outputBlock $ORG1_PEER1_ASSETS/mychannel.block --tls --cafile $FABRIC_CA_CLIENT_TLS_CERTFILES
cp $ORG1_PEER1_ASSETS/mychannel.block $ORG1_PEER2_ASSETS/mychannel.block
cp $ORG1_PEER1_ASSETS/mychannel.block $ORG2_PEER1_ASSETS/mychannel.block
cp $ORG1_PEER1_ASSETS/mychannel.block $ORG2_PEER2_ASSETS/mychannel.block
# # Join peer1-org1 && peer2-org1 to the channel.
docker exec -e "CORE_PEER_MSPCONFIGPATH=${CORE_ORG1_MSPCONFIGPATH}" -e "CORE_PEER_ADDRESS=peer1-org1:7051" cli-org1 peer channel join -b $ORG1_PEER1_ASSETS/mychannel.block --tls --cafile $FABRIC_CA_CLIENT_TLS_CERTFILES
docker exec -e "CORE_PEER_MSPCONFIGPATH=${CORE_ORG1_MSPCONFIGPATH}" -e "CORE_PEER_ADDRESS=peer2-org1:7051" cli-org1 peer channel join -b $ORG1_PEER2_ASSETS/mychannel.block --tls --cafile $FABRIC_CA_CLIENT_TLS_CERTFILES

# Join peer1-org2 && peer2-org2 to the channel.
docker exec -e "CORE_PEER_MSPCONFIGPATH=${CORE_ORG2_MSPCONFIGPATH}" -e "CORE_PEER_ADDRESS=peer1-org2:7051" cli-org2 peer channel join -b $ORG2_PEER1_ASSETS/mychannel.block --tls --cafile $FABRIC_CA_CLIENT_TLS_CERTFILES
docker exec -e "CORE_PEER_MSPCONFIGPATH=${CORE_ORG2_MSPCONFIGPATH}" -e "CORE_PEER_ADDRESS=peer2-org2:7051" cli-org2 peer channel join -b $ORG2_PEER2_ASSETS/mychannel.block --tls --cafile $FABRIC_CA_CLIENT_TLS_CERTFILES
