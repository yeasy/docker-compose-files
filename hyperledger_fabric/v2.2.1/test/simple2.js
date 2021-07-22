'use strict';

const {Gateway, Wallets} = require('fabric-network');
const path = require('path');

const connectionProfileFileName = '/opt/test/connection-profile.json'

async function main() {
// Connect to a gateway peer
  const connectionProfileJson = (await fs.promises.readFile(connectionProfileFileName)).toString();
  const connectionProfile = JSON.parse(connectionProfileJson);
  const wallet = await Wallets.newFileSystemWallet(walletDirectoryPath);
  const gatewayOptions: GatewayOptions = {
    identity: 'user@example.org', // Previously imported identity
    wallet,
  };
  const gateway = new Gateway();
  await gateway.connect(connectionProfile, gatewayOptions);

  try {

    // Obtain the smart contract with which our application wants to interact
    const network = await gateway.getNetwork(channelName);
    const contract = network.getContract(chaincodeId);

    // Submit transactions for the smart contract
    const args = [arg1, arg2];
    const submitResult = await contract.submitTransaction('transactionName', ...args);

    // Evaluate queries for the smart contract
    const evalResult = await contract.evaluateTransaction('transactionName', ...args);

    // Create and submit transactions for the smart contract with transient data
    const transientResult = await contract.createTransaction(transactionName)
      .setTransient(privateData)
      .submit(arg1, arg2);

  } finally {
    // Disconnect from the gateway peer when all work for this client identity is complete
    gateway.disconnect();
  }
}

main()
