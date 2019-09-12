.PHONY: build clean

build:
	cd src && \
	go build -ldflags="-s -w" -o ../bin/bchain bchain.go
	

clean:
	rm -rf ./bin
