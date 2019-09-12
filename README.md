# HyperLedger Fabric CA

This project serves as a basic template to configure a working HyperLedger Fabric CA, based on the document https://hyperledger-fabric-ca.readthedocs.io/en/latest/operations_guide.html

## Build the network

Enter the scripts folder and

* start docker using command  
  ```docker-compose up -d ca-tls rca-org0 rca-org1 rca-org2```
* run ```01.enroll.CAs.sh``` to configure CAs for TLS, org0, org1 and org2 and to setup identities
* run ```02.EnrollOrg1.sh``` to enroll org1 peers and admin
* run ```03.EnrollOrg2.sh``` to enroll org2 peers and admin
* run ```04.EnrollOrderer.sh``` to enroll org0 orderer and admin
* run ```05.Genesis.sh``` to create genesis block and channel transaction
* stop docker using command
  ```docker-compose down```
* restart the full configured environment
  ```docker-compose up -d ca-tls rca-org0 rca-org1 rca-org2 peer1-org1 peer2-org1 peer1-org2 peer2-org2 orderer1-org0 cli-org1 cli-org2```
