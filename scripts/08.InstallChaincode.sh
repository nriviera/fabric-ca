#!/bin/bash
# install-chaincode.sh

LANGUAGE=golang
CC_SRC_PATH=github.com/nriviera/fabric-ca/chaincode
CC_VERSION=$1
CORE_ORG1_MSPCONFIGPATH=/tmp/crypto-config/peerOrganizations/org1/users/admin-org1@org1/msp
CORE_ORG2_MSPCONFIGPATH=/tmp/crypto-config/peerOrganizations/org2/users/admin-org2@org2/msp
CHANNEL_ID=mychannel
FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/tls-ca/crypto/tls-ca-cert.pem

function install_chaincode() {
    if [ -z "$CC_VERSION" ]
    then
        echo "Chaincode version not specified"
    else
        rm -rf /tmp/hyperledger/chaincode
        mkdir -p /tmp/hyperledger/chaincode
        cp -r ../src/chaincode/* /tmp/hyperledger/chaincode
        echo -e "\n\nInstalling chaincode [$CC_SRC_PATH] version $CC_VERSION"
        
        docker exec -e "CORE_PEER_MSPCONFIGPATH=$CORE_ORG1_MSPCONFIGPATH" -e "CORE_PEER_ADDRESS=peer1-org1:7051" cli-org1 peer chaincode install -n acmebc -v $CC_VERSION -p "$CC_SRC_PATH" -l "$LANGUAGE"
        docker exec -e "CORE_PEER_MSPCONFIGPATH=$CORE_ORG1_MSPCONFIGPATH" -e "CORE_PEER_ADDRESS=peer2-org1:7051" cli-org1 peer chaincode install -n acmebc -v $CC_VERSION -p "$CC_SRC_PATH" -l "$LANGUAGE"
        docker exec -e "CORE_PEER_MSPCONFIGPATH=$CORE_ORG2_MSPCONFIGPATH" -e "CORE_PEER_ADDRESS=peer1-org2:7051" cli-org2 peer chaincode install -n acmebc -v $CC_VERSION -p "$CC_SRC_PATH" -l "$LANGUAGE"
        docker exec -e "CORE_PEER_MSPCONFIGPATH=$CORE_ORG2_MSPCONFIGPATH" -e "CORE_PEER_ADDRESS=peer2-org2:7051" cli-org2 peer chaincode install -n acmebc -v $CC_VERSION -p "$CC_SRC_PATH" -l "$LANGUAGE"

        echo "Org1 installed chaincode:"
        docker exec -e "CORE_PEER_MSPCONFIGPATH=$CORE_ORG1_MSPCONFIGPATH" cli-org1 peer chaincode list --installed -o orderer1-org0:7050 -C $CHANNEL_ID
        echo "Org2 installed chaincode:"
        docker exec -e "CORE_PEER_MSPCONFIGPATH=$CORE_ORG2_MSPCONFIGPATH" cli-org2 peer chaincode list --installed -o orderer1-org0:7050 -C $CHANNEL_ID
    fi
}

function instantiate_chaincode() {
    if [ -z "$CC_VERSION" ]
    then
        echo "Chaincode version not specified"
    else
        CC_INST_ORG1=`docker exec -e "CORE_PEER_MSPCONFIGPATH=$CORE_ORG1_MSPCONFIGPATH" cli-org1 peer chaincode list --instantiated -o orderer1-org0:7050 -C $CHANNEL_ID --tls --cafile $FABRIC_CA_CLIENT_TLS_CERTFILES | grep 'acmebc'`
        CC_INST_ORG2=`docker exec -e "CORE_PEER_MSPCONFIGPATH=$CORE_ORG2_MSPCONFIGPATH" cli-org2 peer chaincode list --instantiated -o orderer1-org0:7050 -C $CHANNEL_ID --tls --cafile $FABRIC_CA_CLIENT_TLS_CERTFILES | grep 'acmebc'`
        
        if [ -z "$CC_INST_ORG1$CC_INST_ORG2" ]
        then
            echo -e "\n\nInstantiate chaincode [$CC_SRC_PATH] version $CC_VERSION"
            docker exec -e "CORE_PEER_MSPCONFIGPATH=$CORE_ORG1_MSPCONFIGPATH" cli-org1 peer chaincode instantiate -o orderer1-org0:7050 -C $CHANNEL_ID -n acmebc -l "$LANGUAGE" -v $CC_VERSION -c '{"Args":["init"]}' -P "OR ('org1MSP.member', 'org2MSP.member')" --tls --cafile $FABRIC_CA_CLIENT_TLS_CERTFILES
        else
            echo -e "\n\nUpgrade chaincode [$CC_SRC_PATH] to version $CC_VERSION"
            docker exec -e "CORE_PEER_MSPCONFIGPATH=$CORE_ORG1_MSPCONFIGPATH" cli-org1 peer chaincode upgrade -o orderer1-org0:7050 -C $CHANNEL_ID -n acmebc -l "$LANGUAGE" -v $CC_VERSION -c '{"Args":["init"]}' -P "OR ('org1MSP.member',  'org2MSP.member')" --tls --cafile $FABRIC_CA_CLIENT_TLS_CERTFILES
        fi
    fi
}

install_chaincode
instantiate_chaincode
