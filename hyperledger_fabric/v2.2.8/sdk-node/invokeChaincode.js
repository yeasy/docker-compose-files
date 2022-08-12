const fs = require('fs')
const YAML = require('yaml')
const {Wallets, Gateway, GatewayOptions} = require('fabric-network');

// Load information from the connection profile
const connectionProfileFileName = "/opt/test/connection-profile.yaml"
const connectionProfileYaml = fs.readFileSync(connectionProfileFileName).toString();
const connectionProfile = YAML.parse(connectionProfileYaml);

const orgName = connectionProfile['client']['organization']
const mspId = connectionProfile['organizations'][orgName]['mspid']
const adminUserId = "Admin-" + mspId

const adminCertFile = connectionProfile['organizations'][orgName]['signedCert']['path']
const adminKeyFile = connectionProfile['organizations'][orgName]['adminPrivateKey']['path']
const org1AdminCert = fs.readFileSync(adminCertFile).toString()
const org1AdminKey = fs.readFileSync(adminKeyFile).toString()

const channelName = "businesschannel"
const chaincodeId = "exp02"

const main = async () => {
  const wallet = await Wallets.newFileSystemWallet('/tmp/org1wallet');

  const x509Identity = {
    credentials: {
      certificate: org1AdminCert,
      privateKey: org1AdminKey,
    },
    mspId: mspId,
    type: 'X.509',
  };
  await wallet.put(adminUserId, x509Identity);

  // Connect to a gateway peer
  const gatewayOptions = {
    identity: adminUserId, // Previously imported identity
    wallet: wallet,
    discovery: {enabled: true, asLocalhost: false}
  };
  const gateway = new Gateway();
  await gateway.connect(connectionProfile, gatewayOptions);

  try {
    // Obtain the smart contract with which our application wants to interact
    const network = await gateway.getNetwork(channelName);
    const contract = network.getContract(chaincodeId);

    // Submit transactions for the smart contract
    const args = ['a', 'b', '1'];
    const submitResult = await contract.submitTransaction('invoke', ...args);
    console.log('Invoke transaction has been submitted');

    // Evaluate queries for the smart contract
    const evalResult = await contract.evaluateTransaction('query', 'a');
    console.log('After invoke, the query result = ' + evalResult.toString())

    /*
    // Create and submit transactions for the smart contract with transient data
    const transientResult = contract.createTransaction(transactionName)
        .setTransient(privateData)
        .submit(arg1, arg2);
     */
  } finally {
    // Disconnect from the gateway peer when all work for this client identity is complete
    gateway.disconnect();
  }
  return "Invoke and Query tests are passed!"
};

main()
  .then(console.log)
  .catch(console.error);
