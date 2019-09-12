package blockchain

import (
	"fmt"

	"github.com/hyperledger/fabric-sdk-go/pkg/client/channel"
	"github.com/hyperledger/fabric-sdk-go/pkg/client/event"
	mspclient "github.com/hyperledger/fabric-sdk-go/pkg/client/msp"
	"github.com/hyperledger/fabric-sdk-go/pkg/client/resmgmt"
	"github.com/hyperledger/fabric-sdk-go/pkg/common/errors/retry"
	contextApi "github.com/hyperledger/fabric-sdk-go/pkg/common/providers/context"
	"github.com/hyperledger/fabric-sdk-go/pkg/common/providers/msp"
	"github.com/hyperledger/fabric-sdk-go/pkg/core/config"
	"github.com/hyperledger/fabric-sdk-go/pkg/fabsdk"
	"github.com/pkg/errors"
)

// FabricSetup implementation
type FabricSetup struct {
	ConfigFile      string
	OrgID           string
	OrdererID       string
	ChannelID       string
	ChainCodeID     string
	initialized     bool
	ChannelConfig   string
	ChaincodeGoPath string
	ChaincodePath   string
	OrgAdmin        string
	OrgName         string
	UserName        string
	admin           *resmgmt.Client
	sdk             *fabsdk.FabricSDK
	client          *channel.Client
	event           *event.Client
}

func baseSetup(setup *FabricSetup) error {
	// Add parameters for the initialization
	if setup.initialized {
		return errors.New("sdk already initialized")
	}

	// Initialize the SDK with the configuration file
	sdk, err := fabsdk.New(config.FromFile(setup.ConfigFile))
	if err != nil {
		return errors.WithMessage(err, "failed to create SDK")
	}
	setup.sdk = sdk
	fmt.Println("SDK created")
	return nil
}

// Initialize reads the configuration file and sets up the client, chain and event hub
func (setup *FabricSetup) Initialize() error {
	err := baseSetup(setup)
	if err != nil {
		return err
	}
	// The resource management client is responsible for managing channels (create/update channel)
	resourceManagerClientContext := setup.sdk.Context(fabsdk.WithUser(setup.OrgAdmin), fabsdk.WithOrg(setup.OrgName))
	if err != nil {
		return errors.WithMessage(err, "failed to load Admin identity")
	}
	resMgmtClient, err := resmgmt.New(resourceManagerClientContext)
	if err != nil {
		return errors.WithMessage(err, "failed to create channel management client from Admin identity")
	}
	setup.admin = resMgmtClient
	fmt.Println("Ressource management client created")

	// The MSP client allow us to retrieve user information from their identity, like its signing identity which we will need to save the channel
	mspClient, err := mspclient.New(setup.sdk.Context(), mspclient.WithOrg(setup.OrgName))
	if err != nil {
		return errors.WithMessage(err, "failed to create MSP client")
	}
	adminIdentity, err := mspClient.GetSigningIdentity(setup.OrgAdmin)
	if err != nil {
		return errors.WithMessage(err, "failed to get admin signing identity")
	}

	req := resmgmt.SaveChannelRequest{ChannelID: setup.ChannelID, ChannelConfigPath: setup.ChannelConfig, SigningIdentities: []msp.SigningIdentity{adminIdentity}}
	txID, err := setup.admin.SaveChannel(req, resmgmt.WithOrdererEndpoint(setup.OrdererID))
	if err != nil || txID.TransactionID == "" {
		return errors.WithMessage(err, "failed to save channel")
	}
	fmt.Println("Channel created")

	// Make admin user join the previously created channel
	if err = setup.admin.JoinChannel(setup.ChannelID, resmgmt.WithRetry(retry.DefaultResMgmtOpts), resmgmt.WithOrdererEndpoint(setup.OrdererID)); err != nil {
		return errors.WithMessage(err, "failed to make admin join channel")
	}
	fmt.Println("Channel joined")

	fmt.Println("Initialization Successful")
	setup.initialized = true
	return nil
}

//UserInfo ...
func (setup *FabricSetup) UserInfo(user string) error {
	if setup.sdk == nil {
		err := baseSetup(setup)
		if err != nil {
			return err
		}
	}
	mspClient, err := mspclient.New(setup.sdk.Context(), mspclient.WithOrg(setup.OrgName))
	if err != nil {
		return errors.WithMessage(err, "failed to create MSP client")
	}
	if user == "all" {
		identities, err := mspClient.GetAllIdentities()
		if err != nil {
			return errors.WithMessage(err, fmt.Sprintf("failed to get %s identity", user))
		}
		for _, identity := range identities {
			fmt.Println(fmt.Sprintf("User ID: %s Affiliation: %s Type: %s CAName: %s", identity.ID, identity.Affiliation, identity.Type, identity.CAName))
		}
	} else {
		identity, err := mspClient.GetSigningIdentity(user)
		if err != nil {
			return errors.WithMessage(err, fmt.Sprintf("failed to get %s identity", user))
		}
		fmt.Println(fmt.Sprintf("User %s ID: %s", user, identity.Identifier().ID))
		fmt.Println(fmt.Sprintf("User %s MSPID: %s", user, identity.Identifier().MSPID))
	}
	return nil
}

//CreateChannels ...
func (setup *FabricSetup) CreateChannels() error {
	var err error
	var clientContext contextApi.ChannelProvider
	if setup.sdk == nil {
		err := baseSetup(setup)
		if err != nil {
			return err
		}
	}
	// Channel client is used to query and execute transactions
	if setup.client == nil {
		fmt.Println("--> CREATE Channel client")
		clientContext = setup.sdk.ChannelContext(setup.ChannelID, fabsdk.WithUser(setup.UserName))
		setup.client, err = channel.New(clientContext)
		if err != nil {
			return errors.WithMessage(err, "failed to create new channel client")
		}
		fmt.Println("Channel client created")
	}
	if setup.event == nil {
		fmt.Println("--> CREATE Event client")
		if clientContext == nil {
			clientContext = setup.sdk.ChannelContext(setup.ChannelID, fabsdk.WithUser(setup.UserName))
		}
		// Creation of the client which will enables access to our channel events
		setup.event, err = event.New(clientContext)
		if err != nil {
			return errors.WithMessage(err, "failed to create new event client")
		}
		fmt.Println("Event client created")
	}
	return nil
}

//CloseSDK ...
func (setup *FabricSetup) CloseSDK() {
	if setup.sdk != nil {
		setup.sdk.Close()
	}
}
