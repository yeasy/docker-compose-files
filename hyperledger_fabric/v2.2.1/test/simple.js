'use strict';

const fs = require('fs')

const {Gateway, gatewayOptions} = require('fabric-network');

async function main() {

// read a common connection profile in json format
  const data = fs.readFileSync('/opt/test/connection-profile.json');
  const connectionProfile = JSON.parse(data);

  const user =
  {
    credentials: {
        certificate: '-----BEGIN CERTIFICATE-----MIICKDCCAc+gAwIBAgIQSdBFJUgRkBhzmW9htYh+UjAKBggqhkjOPQQDAjBzMQswCQYDVQQGEwJVUzETMBEGA1UECBMKQ2FsaWZvcm5pYTEWMBQGA1UEBxMNU2FuIEZyYW5jaXNjbzEZMBcGA1UEChMQb3JnMS5leGFtcGxlLmNvbTEcMBoGA1UEAxMTY2Eub3JnMS5leGFtcGxlLmNvbTAeFw0yMDA3MTcxODE5MDBaFw0zMDA3MTUxODE5MDBaMGsxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpDYWxpZm9ybmlhMRYwFAYDVQQHEw1TYW4gRnJhbmNpc2NvMQ4wDAYDVQQLEwVhZG1pbjEfMB0GA1UEAwwWQWRtaW5Ab3JnMS5leGFtcGxlLmNvbTBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABJ2unYyG7FEY9oSq2tgtR7AMc0tto36cbwsLHEQ6aVPPwZAjkuTij6MpQxMf8gfLlw6cdBA898bGrL2DlttnwM6jTTBLMA4GA1UdDwEB/wQEAwIHgDAMBgNVHRMBAf8EAjAAMCsGA1UdIwQkMCKAIKqf36g/sCvMlxb5pAHInL/lz2U6RJfYRzgbC38Wrp5QMAoGCCqGSM49BAMCA0cAMEQCIBL+/AwRBeh13pl+cY8ZlcJsNPDXPDc41wKKche8zdSSAiB5i5Lu+1Tnoy4T4l3DSf2K8xrx9UgFNn73kGfpYR12UQ==-----END CERTIFICATE-----',
        privateKey: '-----BEGIN PRIVATE KEY-----MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQg4ui7zz4MlrLCpncsYHdQQS6qp8M5JE3f8ZowaU+BBfahRANCAASdrp2MhuxRGPaEqtrYLUewDHNLbaN+nG8LCxxEOmlTz8GQI5Lk4o+jKUMTH/IHy5cOnHQQPPfGxqy9g5bbZ8DO-----END PRIVATE KEY-----',
    },
    mspId: 'Org1MSP',
    type: 'X.509',
};

// use the loaded connection profile
  const gateway = new Gateway();
  await gateway.connect(connectionProfile, { identity: user});

  const network = await gateway.getNetwork('businesschannel');
}

main()