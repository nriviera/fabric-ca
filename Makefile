.PHONY: config build clean


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
