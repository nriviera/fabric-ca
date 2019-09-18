# HyperLedger Fabric CA

This project serves as a basic template to configure a working HyperLedger Fabric CA, based on the document https://hyperledger-fabric-ca.readthedocs.io/en/latest/operations_guide.html

## Build the network

* Start CAs using
  ```make run-ca```
* Setup network using
  ```make config```
* Stop CAs using
  ```make stop```
* Start the network using
  ```make run-network```

otherwise you can enter the scripts folder and

* start docker using command  
  ```docker-compose up -d ca-tls rca-org0 rca-org1 rca-org2```
* run ```01.enroll.CAs.sh``` to configure CAs for TLS, org0, org1 and org2 and to setup identities
* run ```02.EnrollOrg1.sh``` to enroll org1 peers and admin
* run ```03.EnrollOrg2.sh``` to enroll org2 peers and admin
* run ```04.EnrollOrg0.sh``` to enroll org0 orderer and admin
* run ```05.Genesis.sh``` to create genesis block and channel transaction
* stop docker using command
  ```docker-compose down```
* restart the full configured environment
  ```docker-compose up -d ca-tls rca-org0 rca-org1 rca-org2 peer1-org1 peer2-org1 peer1-org2 peer2-org2 orderer1-org0 cli-org1 cli-org2```

## Build the client

### Generate config

* Setup client configurations
  ```make client-config```

otherwise you can enter the scripts folder and

* run ```06.ClientSetup.sh /tmp``` to generate client config

### Build channel and deploy chaincode

* Create and join channel
  ```make channels```

otherwise you can enter the scripts folder and

* run ```07.CreateChannel.sh``` to create and join channel
* run ```08.InstallChaincode.sh``` to install and instantiate the chaincode

### Build the app

* run ```make build``` from project root folder. Binaries are built in ```bin``` folder

### Start Explorer

* run ```make explorer``` to setup hyperledger explorer
* point the browser to localhost:9090 and log in with login:admin-org1 password:org1AdminPW

* run ```make stop-explorer``` when done
