
### Start network with CouchDB

```bash
docker-compose -f docker-compose-2orgs-4peers.yaml -f docker-compose-2orgs-4peers-couchdb.yaml up
```

To use CouchDB instead of the default database leveldb, The same chaincode functions are available with CouchDB, however, there is the
added ability to perform rich and complex queries against the state database
data content contingent upon the chaincode data being modeled as JSON

### Test chaincode_example02

```bash
docker exec -it fabric-cli bash

bash ./scripts/initialize.sh

bash ./scripts/test_4peers.sh
```

You can use chaincode_example02 chaincode against the CouchDB state database
using the steps outlined above, however in order to exercise the CouchDB query
capabilities you will need to use a chaincode that has data modeled as JSON.
(e.g. marbles02)

### [WIP] [Test example marbles02](https://github.com/hyperledger/fabric/blob/master/examples/chaincode/go/marbles02/marbles_chaincode.go)

### Interact with CouchDb by WEB-UI

The browser is `http://localhost:5984/_utils`, then you will find a database named `businesschannel`
 