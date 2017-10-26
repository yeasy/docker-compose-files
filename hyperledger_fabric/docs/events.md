## Events 
Events didn't support TLS, so make sure TLS has been disabled by setting *_TLS_ENABLED=false in peer-base.yaml and orderer-base.yaml
Next, start the network with following command:
```bash
$ bash scripts/start_fabric.sh docker-compose-2orgs-4peers-event.yaml
```

when the network starts successfully, we started a block-listener in container `fabric-event-listener`.
so observe the output of the service fabric-event-listener.

Listening logs at a new terminal,
 
```bash
$ docker logs -f fabric-event-listener
```

So when we do chaincode operations in container `fabric-cli`, 

```bash
$ docker exec -it fabric-cli bash
$ bash ./scripts/initialize.sh
```

then we will get some events at listening terminal looks like following:

```bash
Received block
--------------
Received transaction from channel businesschannel: 
	[header:<channel_header:"\010\003\032\014\010\305\326\216\312\005\020\371\326\244\314\003\"\017businesschannel*@
	633caf1cd9796d49a58898c873bd10055867113f4eeb051a057acbce7df0ed59:\010\022\006\022\004lscc" 
	signature_header:"\n\250\006\n\007Org2MSP\022\234\006-----BEGIN...
```