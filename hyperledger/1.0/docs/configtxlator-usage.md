## Start the configtxlator

First start a fabric network with docker-compose-2orgs-4peers.yaml, and make sure the network can work, 
then we will use `configtxlator` to start an http server listening on the designated port and process request.

```bash
$ docker exec -it fab-cli bash
$ configtxlator start
UTC [configtxlator] startServer -> INFO 001 Serving HTTP requests on 0.0.0.0:7059

```
This logs appears, indicating startup successful.

## Function

### translation

#### /protolator/decode/{msgName}

Any of the configuration related protos, including `common.Block`, `common.Envelope`, `common.ConfigEnvelope`,
`common.ConfigUpdateEnvelope`, `common.Configuration`, and `common.ConfigUpdate` are valid targets for these URLs.
this will produces human readable version of config, such as translate to json

Execute following command in new terminal,
```bash
$ docker exec -it fabric-cli bash
$ cd channel-artifacts
$ curl -X POST --data-binary @businesschannel_0.block http://127.0.0.1:7059/protolator/decode/common.Block > businesschannel_0.json
```

for channel.tx, use following msgType.

```bash
curl -X POST --data-binary @channel.tx http://127.0.0.1:7059/protolator/decode/common.Envelope > channel.json
```

#### /protolator/encode/{msgName}

And we can transform json to proto.
```bash
$ curl -X POST --data-binary @businesschannel_0.json http://127.0.0.1:7059/protolator/encode/common.Block > businesschannel_0.block
```

### Re-Configuration

Refer to [create a new ordering system channel](http://hyperledger-fabric.readthedocs.io/en/latest/configtxlator.html#reconfiguration-example)

### [WIP]/configtxlator/compute/update-from-configs


### [WIP]/configtxlator/config/verify
