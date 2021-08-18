"use strict";

const fs = require('fs');
const path = require('path');
const {Endorser, Endpoint, Discoverer} = require('fabric-common');
const Client = require('fabric-common/lib/Client');
const User = require('fabric-common/lib/User');
const Signer = require('fabric-common/lib/Signer');
const Utils = require('fabric-common/lib/Utils');
const {common: commonProto} = require('fabric-protos');
const {Gateway} = require('fabric-network');
const IdentityContext = require('fabric-common/lib/IdentityContext');

const mspId = 'Org1MSP';
const peerURL = `grpcs://peer1.org1.example.com:7051`;
const channelName = 'businesschannel';
const baseMSPPath='../crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp'
const tlsCAPath = path.resolve(baseMSPPath+'/tlscacerts/tlsca.org1.example.com-cert.pem');
const signCertPath = path.resolve(baseMSPPath+'/signcerts/Admin@org1.example.com-cert.pem');
const signKeyPath = path.resolve(baseMSPPath+'/keystore/priv_sk');

const chaincodeId = 'exp02';
const fcn = 'query';
const args = ['a'];

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
    //---- query on chaincode
    return queryChaincode(channelName, chaincodeId, fcn, args, endorser, user)

};

/**
 * Get the blockchain info from given channel
 * @param {string} channelName Channel to fetch blockchain info
 * @param {string} chaincodeId Id of the chaincode
 * @param {string} fcn Chaincode method to call
 * @param {array} args Chaincode method arguments
 * @param {Endorser} endorser Endorser to send the request to
 * @param {User} user Identity to use
 * @returns {BlockchainInfo} Parsed blockchain info struct
 */
const queryChaincode = async (channelName,chaincodeId, fcn, args, endorser, user) => {
    let result = await  callChaincode(channelName, chaincodeId, fcn, args, endorser, user)
    return parseQueryResponse(result)
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

/**
 * Parse the query result
 * @param _resultProto
 * @returns {string}
 */
const parseQueryResponse = (_resultProto) => {
    return _resultProto.toString()
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
