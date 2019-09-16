.PHONY: run-ca run-network config build clean

run-ca:
	cd scripts && docker-compose up -d ca-tls rca-org0 rca-org1 rca-org2

run-network:
	cd scripts && docker-compose up -d ca-tls rca-org0 rca-org1 rca-org2 peer1-org1 peer2-org1 peer1-org2 peer2-org2 orderer1-org0 cli-org1 cli-org2

stop:
	cd scripts && docker-compose down -v
	
config:
	cd scripts && ./01.enroll.CAs.sh
	cd scripts && ./02.EnrollOrg1.sh
	cd scripts && ./03.EnrollOrg2.sh
	cd scripts && ./04.EnrollOrg0.sh
	cd scripts && ./05.Genesis.sh

build:
	cd src && \
	go build -ldflags="-s -w" -o ../bin/bchain bchain.go
	

clean:
	rm -rf ./bin
	rm -rf /tmp/hyperledger
