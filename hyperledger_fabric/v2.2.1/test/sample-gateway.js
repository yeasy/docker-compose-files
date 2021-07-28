const fs = require('fs')
const {Wallets, Gateway, GatewayOptions} = require('fabric-network');
const {Client, Endorser, Endpoint, Discoverer} = require('fabric-common');

const connectionProfileFileName = "./connection-profile.json"
const org1AdminTLSClientCert = fs.readFileSync("/opt/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/tls/client.crt").toString()
const org1AdminTLSClientKey = fs.readFileSync("/opt/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/tls/client.key").toString()
const org1AdminCert = fs.readFileSync("/opt/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/Admin@org1.example.com-cert.pem").toString()
const org1AdminKey = fs.readFileSync("/opt/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/priv_sk").toString()
const connectionProfileJson = fs.readFile(connectionProfileFileName).toString();
const connectionProfile = JSON.parse(connectionProfileJson);

const mspId = "Org1MSP"
const adminUserId="Admin@org1"
const channelName = "businesschannel"
const chaincodeId="exp02"

// Connect to a gateway peer
const wallet = Wallets.newFileSystemWallet('/tmp/org1wallet');

const x509Identity = {
    credentials: {
        certificate: org1AdminCert,
        privateKey: org1AdminKey.toBytes(),
    },
    mspId: mspId,
    type: 'X.509',
};
wallet.put(adminUserId, x509Identity);

const gatewayOptions = {
    identity: adminUserId, // Previously imported identity
    wallet,
};
const gateway = new Gateway();
gateway.connect(connectionProfile, gatewayOptions);

try {

    // Obtain the smart contract with which our application wants to interact
    const network = gateway.getNetwork(channelName);
    const contract = network.getContract(chaincodeId);

    // Submit transactions for the smart contract
    const args = [arg1, arg2];
    const submitResult = contract.submitTransaction('transactionName', ...args);

    // Evaluate queries for the smart contract
    const evalResult = contract.evaluateTransaction('transactionName', ...args);

    // Create and submit transactions for the smart contract with transient data
    const transientResult = contract.createTransaction(transactionName)
        .setTransient(privateData)
        .submit(arg1, arg2);

} finally {
    // Disconnect from the gateway peer when all work for this client identity is complete
    gateway.disconnect();
}