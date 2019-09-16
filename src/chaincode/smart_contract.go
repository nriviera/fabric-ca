package main

import (
	"encoding/json"
	"fmt"
	"strconv"
	"strings"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	sc "github.com/hyperledger/fabric/protos/peer"
)

//AntiPiracyTRXSmartContract Define the Smart Contract structure
type AntiPiracyTRXSmartContract struct {
}

//Trx ...
type Trx struct {
	When int64  `json:"when"`
	What string `json:"what"`
	Who  string `json:"who"`
	Raw  string `json:"raw"`
}

/*
 * The Init method is called when the Smart Contract "fabcar" is instantiated by the blockchain network
 * Best practice is to have any Ledger initialization in separate function -- see initLedger()
 */
func (s *AntiPiracyTRXSmartContract) Init(APIstub shim.ChaincodeStubInterface) sc.Response {
	fmt.Println("# AntiPiracy Chaincode Init #")
	// Get the function and arguments from the request
	function, args := APIstub.GetFunctionAndParameters()
	if len(args) > 0 {
		return shim.Error("Incorrect number of arguments. Expecting none")
	}
	// Check if the request is the init function
	if function != "init" {
		return shim.Error("Unknown function call")
	}
	return shim.Success(nil)
}

/*
 * The Invoke method is called as a result of an application request to run the Smart Contract "fabcar"
 * The calling application program has also specified the particular smart contract function to be called, with arguments
 */
func (s *AntiPiracyTRXSmartContract) Invoke(APIstub shim.ChaincodeStubInterface) sc.Response {
	// Retrieve the requested Smart Contract function and arguments
	function, args := APIstub.GetFunctionAndParameters()
	fmt.Println(fmt.Sprintf("# AntiPiracy Chaincode Invoke %s(%s)#", function, strings.Join(args, ",")))

	// Route to the appropriate handler function to interact with the ledger appropriately
	if function == "createTrx" {
		return s.createTrx(APIstub, args)
	} else if function == "queryTrx" {
		return s.queryTrx(APIstub, args)
	}
	return shim.Error(fmt.Sprintf("Invalid Smart Contract function name [%s].", function))
}

func (s *AntiPiracyTRXSmartContract) createTrx(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
	if len(args) != 4 {
		return shim.Error("Incorrect number of arguments. Expecting 4 [when, what, who, rawdata]")
	}
	t := Trx{}
	t.When, _ = strconv.ParseInt(args[0], 10, 64)
	t.What = args[1]
	t.Who = args[2]
	t.Raw = args[3]

	trxBytes, _ := json.Marshal(t)
	key := fmt.Sprintf("trx%d", t.When)
	fmt.Println(fmt.Sprintf("Creating Trx %s [%s]", key, string(trxBytes)))
	err := APIstub.PutState(key, trxBytes)
	if err != nil {
		return shim.Error(err.Error())
	}
	// Notify listeners that an event "createTrxRvent" have been executed
	err = APIstub.SetEvent("createTrxRvent", []byte{})
	if err != nil {
		return shim.Error(err.Error())
	}
	return shim.Success(nil)
}

func (s *AntiPiracyTRXSmartContract) queryTrx(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1 [when]")
	}
	key := fmt.Sprintf("trx%s", args[0])
	body, err := APIstub.GetState(key)
	fmt.Println(fmt.Sprintf("State of %s is [%s]", key, string(body)))
	if body == nil {
		return shim.Error(fmt.Sprintf("%s is empty", key))
	}
	if err != nil {
		return shim.Error(fmt.Sprintf("Failed to get state of %s", key))
	}
	return shim.Success(body)
}

func main() {
	// Start the chaincode and make it ready for futures requests
	err := shim.Start(new(AntiPiracyTRXSmartContract))
	if err != nil {
		fmt.Printf("Error starting AntiPiracyTRXSmartContract chaincode: %s", err)
	}
}
