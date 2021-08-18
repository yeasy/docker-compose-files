"use strict";

const fs = require('fs');
const path = require('path');
const User = require('fabric-common/lib/User');
const Signer = require('fabric-common/lib/Signer');
const Utils = require('fabric-common/lib/Utils');
const {common: commonProto} = require('fabric-protos');
const {Wallets} = require('fabric-network');

const mspId = 'Org1MSP';
const baseMSPPath='../crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp'
const signCertPath = path.resolve(baseMSPPath+'/signcerts/Admin@org1.example.com-cert.pem');
const signKeyPath = path.resolve(baseMSPPath+'/keystore/priv_sk');

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
    const user = loadUser('testAdmin', signCert, signKey);
    const identity = new gwSigningIdentity(user._signingIdentity);
    const wallet = await Wallets.newFileSystemWallet('/opt/test/wallet');
    await wallet.put(mspId+'-admin', identity);
    return "wallet is created"
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
