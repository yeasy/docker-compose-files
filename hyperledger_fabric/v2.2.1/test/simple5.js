'use strict';

// work with native fabric

const fs = require('fs')

const {Client, Endorser, Endpoint, Discoverer} = require('fabric-common');

async function main() {
  const peer1TLSCACert = fs.readFileSync("/opt/crypto-config/peerOrganizations/org1.example.com/tlsca/tlsca.org1.example.com-cert.pem").toString()
  const org1AdminTLSClientCert = fs.readFileSync("/opt/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/tls/client.crt").toString()
  const org1AdminTLSClientKey = fs.readFileSync("/opt/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/tls/client.key").toString()

  const peerURL = "grpcs://peer1.org1.example.com:7051"
  const mspId = "Org1MSP"

  const client = new Client('myclient');
  const endpoint = new Endpoint({
    url: peerURL,
    pem: peer1TLSCACert,
    'grpc-wait-for-ready-timeout': 30000
  });

  // test using endorser
  const endorser = new Endorser("myEndorser", {}, mspId);
  endorser.setEndpoint(endpoint);
  //await endorser.resetConnection()
  let isConnected = await endorser.checkConnection()
  console.log("before, isConnected=", isConnected)

  //await endorser.connect(endpoint)
  //isConnected = await endorser.checkConnection()
  //console.log("after, isConnected=", isConnected)

  // TODO: Not working well now, always return true.
  if (endorser.hasChaincode("exp03") === true) {
    console.log("Peer has chaincode")
  } else {
    console.log("Peer does not have chaincode")
  }

  // test using discoverer
  const discoverer = new Discoverer("myDiscoverer", {}, mspId);
  discoverer.setEndpoint(endpoint);
  //await discoverer.resetConnection()
  await discoverer.connect(endpoint)

  isConnected = await discoverer.checkConnection()
  console.log("discover isConnected=", isConnected)
}

main()