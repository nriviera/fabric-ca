package blockchain

import (
	"fmt"
	"time"

	"github.com/hyperledger/fabric-sdk-go/pkg/client/channel"
)

// QueryTRX ...
func (setup *FabricSetup) QueryTRX(num string) (string, error) {
	// Prepare arguments
	var args []string
	args = append(args, "queryTrx")
	args = append(args, num)

	response, err := setup.client.Query(channel.Request{ChaincodeID: setup.ChainCodeID, Fcn: args[0], Args: [][]byte{[]byte(args[1])}})
	if err != nil {
		return "", fmt.Errorf("failed to query: %v", err)
	}

	return string(response.Payload), nil
}

//CreateTRX ...
func (setup *FabricSetup) CreateTRX(when string, what string, who string, raw string) (string, error) {
	// Prepare arguments
	var args []string
	args = append(args, "createTrx")
	args = append(args, when)
	args = append(args, what)
	args = append(args, who)
	args = append(args, raw)

	eventID := "createTrxRvent"
	reg, notifier, err := setup.event.RegisterChaincodeEvent(setup.ChainCodeID, eventID)
	if err != nil {
		return "", err
	}
	defer setup.event.Unregister(reg)

	response, err := setup.client.Execute(channel.Request{ChaincodeID: setup.ChainCodeID, Fcn: args[0], Args: [][]byte{[]byte(args[1]), []byte(args[2]), []byte(args[3]), []byte(args[4])}})
	if err != nil {
		return "", fmt.Errorf("failed to query: %v", err)
	}

	select {
	case ccEvent := <-notifier:
		fmt.Printf("Received CC event: %v\n", ccEvent)
	case <-time.After(time.Second * 20):
		return "", fmt.Errorf("did NOT receive CC event for eventId(%s)", eventID)
	}

	return string(response.TransactionID), nil
}
