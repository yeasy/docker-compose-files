"use strict";

const fs = require('fs');
const path = require('path');
const {Endorser, Endpoint, Discoverer} = require('fabric-common');
const Client = require('fabric-common/lib/Client');
const User = require('fabric-common/lib/User');
const Signer = require('fabric-common/lib/Signer');
const Utils = require('fabric-common/lib/Utils');
const {common: commonProto} = require('fabric-protos');
const {Gateway, Wallets} = require('fabric-network');
const IdentityContext = require('fabric-common/lib/IdentityContext');

const mspId = 'Org1MSP';
const peerURL = `grpcs://peer1.org1.example.com:7051`;
const channelName = 'businesschannel';
const tlsCAPath = path.resolve('../crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/tlscacerts/tlsca.org1.example.com-cert.pem');
const signCertPath = path.resolve('../crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/Admin@org1.example.com-cert.pem');
const signKeyPath = path.resolve('../crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/priv_sk');

const tlsCACert = fs.readFileSync(tlsCAPath).toString();
const signCert = fs.readFileSync(signCertPath).toString();
const signKey = fs.readFileSync(signKeyPath).toString();

class gwSigningIdentity {
    constructor(signingIdentity) {
        this.type = 'X.509';
        this.mspId = signingIdentity._mspId;
        this.credentials = {
            certificate: signingIdentity._certificate.toString().trim(),
            privateKey: signingIdentity._signer._key.toBytes().trim(),
        };
    }
}

/**
 * Main entrance method
 * @returns {Promise<*>}
 */
const main = async () => {
    const options = {
        url: peerURL,
        'grpc-wait-for-ready-timeout': 30000,
        pem: tlsCACert
        //'grpc.ssl_target_name_override': peerHost
    };
    const endpoint = new Endpoint(options);
    const endorser = new Endorser('myEndorser', {}, mspId);
    endorser.setEndpoint(endpoint);
    await endorser.connect();

    // Only for test purpose, safe to remove following 3 lines
    const discoverer = new Discoverer('myDiscoverer', {}, mspId);
    discoverer.setEndpoint(endpoint);
    await discoverer.connect();

    const user = loadUser('test-Admin', signCert, signKey);
    //---- query on system chaincode to getChainInfo
    return getBlockchainInfo(channelName, endorser, user)
};

/**
 * Get the blockchain info from given channel
 * @param {string} channelName Channel to fetch blockchain info
 * @param {Endorser} endorser Endorser to send the request to
 * @param {User} user Identity to use
 * @returns {BlockchainInfo} Parsed blockchain info struct
 */
const getBlockchainInfo = async (channelName, endorser, user) => {
    const chaincodeId = 'qscc';
    const fcn = 'GetChainInfo';
    const args = [channelName];

    let result = await  callChaincode(channelName, chaincodeId, fcn, args, endorser, user)
    return parseBlockchainInfo(result)
}

/**
 * Call a chaincode and return the response in raw proto
 * @param {string} channelName Name of the channel
 * @param {string} chaincodeId Name of the chaincode
 * @param {string} fcn Name of the chaincode method to call
 * @param {string} args Parameters for the Chaincode method
 * @param {Endorser} endorser Endorser to send the request to
 * @param {User} user Identity to use
 * @returns {Promise<Buffer>}
 */
const callChaincode = async (channelName, chaincodeId, fcn, args, endorser, user) => {
    const gateWay = new Gateway();
    const client = new Client(null);
    const identity = new gwSigningIdentity(user._signingIdentity);
    gateWay.identity = identity;
    gateWay.identityContext = new IdentityContext(user, client);

    // test wallet, safe to remove following 2 lines
    //const wallet = await Wallets.newFileSystemWallet('/opt/test/wallet');
    //await wallet.put('org1admin', identity);

    const channel = client.newChannel(channelName);
    client.channels.set(channelName, channel);
    channel.getEndorsers = () => Array.from(channel.endorsers.values());
    channel.endorsers.set(endorser.toString(), endorser);

    await gateWay.connect(client, {
        wallet: {}, discovery: {enabled: false}, identity
    });

    const network = await gateWay.getNetwork(channelName);
    const contract = network.getContract(chaincodeId);
    const tx = contract.createTransaction(fcn);
    //const response = contract.evaluateTransaction(fcn, args)

    return tx.evaluate(...args);
}

/**
 * Parse the result into the blockchain info structure
 * @param {Buffer} _resultProto The original result from fabric network
 * @returns {{previousBlockHash: string, currentBlockHash: string, height: number}}
 */
const parseBlockchainInfo = (_resultProto) => {
    const {height, currentBlockHash, previousBlockHash} = commonProto.BlockchainInfo.decode(_resultProto);
    return {
        height: height.toInt(),
        currentBlockHash: currentBlockHash.toString('hex'),
        previousBlockHash: previousBlockHash.toString('hex'),
    };
};

/**
 * Construct a user object based on given cert and key strings
 * @param {string} name Name to assign to the user
 * @param {string} signCert Certificate string to sign
 * @param {string} signKey Private key string to sign
 * @returns {User} User object
 */
const loadUser = (name, signCert, signKey) => {
    const SigningIdentity = require('fabric-common/lib/SigningIdentity');
    const user = new User(name);
    user._cryptoSuite = Utils.newCryptoSuite();
    const privateKey = user._cryptoSuite.createKeyFromRaw(signKey);
    const {_cryptoSuite} = user;
    const pubKey = _cryptoSuite.createKeyFromRaw(signCert);
    user._signingIdentity = new SigningIdentity(signCert, pubKey, mspId, _cryptoSuite, new Signer(_cryptoSuite, privateKey));
    user.getIdentity = () => {
        return user._signingIdentity;
    };
    return user;
};

main()
    .then(console.log)
    .catch(console.error);
