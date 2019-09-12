package main

import (
	"flag"
	"fmt"
	"os"
	"strings"

	blockchain "github.com/nriviera/fabric-ca/blockchain"
)

func initBC(fSetup *blockchain.FabricSetup) error {
	// Initialization of the Fabric SDK from the previously set properties
	err := fSetup.Initialize()
	if err != nil {
		fmt.Printf("Unable to initialize the Fabric SDK: %v\n", err)
	}
	return err
}

func createClientChannel(fSetup *blockchain.FabricSetup) error {
	err := fSetup.CreateChannels()
	if err != nil {
		fmt.Printf("Unable to initialize the Fabric SDK: %v\n", err)
	}
	return err
}

func query(args []string, fSetup *blockchain.FabricSetup) {
	var resp string
	var err error
	if strings.ToUpper(args[0]) == "QUERY" {
		resp, err = fSetup.QueryTRX(args[1])
	} else if strings.ToUpper(args[0]) == "CREATETRX" {
		resp, err = fSetup.CreateTRX(args[1], args[2], args[3], args[4])
	}

	if err != nil {
		fmt.Println(err)
		return
	}
	fmt.Println(fmt.Sprintf("%s -> %s", args[0], resp))
}

func main() {
	initPtr := flag.Bool("init", false, "initialize blockchain")
	queryPtr := flag.Bool("invoke", false, "invoke operation")
	cfgFile := flag.String("config", "/Users/cornoro/projects/aws/anti_piracy/sls_backend/tests/hl-config.yaml", "config file")
	userPtr := flag.String("user", "", "user info")
	flag.Parse()

	// Definition of the Fabric SDK properties
	fSetup := blockchain.FabricSetup{
		// Network parameters
		OrdererID: "orderer.example.com",

		// Channel parameters
		ChannelID:     "mychannel",
		ChannelConfig: "/Users/cornoro/projects/aws/anti_piracy/sls_backend/resources/blockchain/config/channel.tx",

		// Chaincode parameters
		ChainCodeID:     "acmebc",
		ChaincodeGoPath: os.Getenv("GOPATH"),
		ChaincodePath:   "skygit.it.nttdata-emea.com/antipiracy/chaincode/",
		OrgAdmin:        "Admin",
		OrgName:         "org1",
		ConfigFile:      *cfgFile,

		// User parameters
		UserName: "User1",
	}

	if initPtr != nil && *initPtr {
		initBC(&fSetup)
	}
	if queryPtr != nil && *queryPtr {
		err := fSetup.CreateChannels()
		if err == nil {
			query(flag.Args(), &fSetup)
		} else {
			fmt.Println("Error:", err.Error())
		}
	}
	if userPtr != nil && *userPtr != "" {
		err := fSetup.UserInfo(*userPtr)
		if err != nil {
			fmt.Println("Error:", err.Error())
		}
	}
	// Close SDK
	defer fSetup.CloseSDK()
}
