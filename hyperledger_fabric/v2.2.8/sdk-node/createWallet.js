"use strict";

const fs = require('fs');
const path = require('path');
const {common: commonProto} = require('fabric-protos');
const {Wallets} = require('fabric-network');

const mspId = 'Org1MSP';
const baseMSPPath = '../crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp'
const signCertPath = path.resolve(baseMSPPath + '/signcerts/Admin@org1.example.com-cert.pem');
const signKeyPath = path.resolve(baseMSPPath + '/keystore/priv_sk');

const signCert = fs.readFileSync(signCertPath).toString();
const signKey = fs.readFileSync(signKeyPath).toString();

/**
 * Main entrance method
 * @returns {Promise<*>}
 */
const main = async () => {
  const wallet = await Wallets.newFileSystemWallet('/opt/test/wallet');

  const x509Identity = {
    credentials: {
      certificate: signCert,
      privateKey: signKey,
    },
    mspId: mspId,
    type: 'X.509',
  };
  await wallet.put(mspId + '-admin', x509Identity);

  return "wallet is created"
};

main()
  .then(console.log)
  .catch(console.error);
