.PHONY: build run-ca run-network config client-config clean channels

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

client-config:
	cd scripts && ./06.ClientSetup.sh /tmp

channels:
	cd scripts && ./07.CreateChannel.sh
	cd scripts && ./08.InstallChaincode.sh 1.0

build:
	cd src/client && \
	go build -ldflags="-s -w" -o ../../bin/bchain bchain.go
	
clean:
	rm -rf ./bin
	rm -rf /tmp/hyperledger
	rm -rf /tmp/client-config.yaml
	rm -rf /tmp/crypto-config
	rm -rf /tmp/explorer
	rm -rf /tmp/prometheus
	rm -rf /tmp/grafana
