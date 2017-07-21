## Chaincode Tests

All the test command needs to be executed inside the `fabric-cli` container.

Use the following command to login into the container fabric-cli 

```bash
$ docker exec -it fabric-cli bash
```

After finish the chaincode tests, you can log-out by `exit`.


### Chaincode Operations

You can execute some chaincode operations, such as `query` or `invoke`,
and you can modify the parameters and execute this script repeatedly.

```bash
$ bash ./scripts/test_4peers.sh  #execute in container fabric-cli
```

You should see the following output:

```bash
UTC [msp] GetLocalMSP -> DEBU 004 Returning existing local MSP
UTC [msp] GetDefaultSigningIdentity -> DEBU 005 Obtaining default signing identity
UTC [msp/identity] Sign -> DEBU 006 Sign: plaintext: 0AB7070A6D08031A0C08C3EAE9C90510...6D7963631A0A0A0571756572790A0161 
UTC [msp/identity] Sign -> DEBU 007 Sign: digest: FA308EF50C4812BADB60D58CE15C1CF41089EFB93B27D46885D92C92F55E98A0 
Query Result: 80
UTC [main] main -> INFO 008 Exiting.....
===================== Query on PEER3 on channel 'businesschannel' is successful ===================== 

===================== All GOOD, End-2-End execution completed ===================== 
```
