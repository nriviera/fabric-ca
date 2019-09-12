.PHONY: build clean

build:
	env go build -ldflags="-s -w" -o ./bin/bchain src/bchain.go

clean:
	rm -rf ./bin
