#Fabric CA Example

##Run the sample
* Start: go to fabric-ca/fabric-1.2 and run the start.sh script
* Stop:  go to fabric-ca/fabric-1.2 and run the stop.sh script

##How does it work
 * The docker named "setup" registers and enrolls USER identities from CA and writes them in the "crypto-config" directory in a compatible structure from Cello
 * The "setup" docker also generates genesis block from configtx.yml
 * The peer nodes registers and enrolls PEER identities from CA and writes them in the "crypto-config" directory in the similar structure
 * For testing, The "setup" docker also generates channel configuration transaction and the "run" docker will use the Admin identity of a peer node to create channel, deploy and invoke chaincode
 * The scripts exextued by corresponding docker is stored in fabric-ca/scripts

##Inspect results and logs
 * The logs for each docker is stored in fabric-ca/fabric-1.2/logs
 * There are some files functionning as marks to indicate whether setup-fabric or run-fabirc is successful
 * The run.sum file record the process of creating channel, deploying and invoking chaincode

