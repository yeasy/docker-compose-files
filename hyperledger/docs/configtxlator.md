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

### Re-Configuration example

1. here we will introduce how to re-configuration config.block, first fetch the block and translate it to json.

```bash
$ ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

$ peer channel fetch config -o orderer.example.com:7050 -c businesschannel --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA|xargs mv true config_block.pb

$ peer channel fetch config config_block.pb -o orderer.example.com:7050 -c businesschannel # with no-tls

$ curl -X POST --data-binary @config_block.pb http://127.0.0.1:7059/protolator/decode/common.Block > config_block.json
```

2. Extract the config section from the block:

```bash
$ apt-get install jq
$ jq .data.data[0].payload.data.config config_block.json > config.json
```

3. edit the config.json, set the batch size to 11, and saving it as update_config.json

```bash
4. $ jq ".channel_group.groups.Orderer.values.BatchSize.value.max_message_count = 11" config.json  > updated_config.json
```

5. Re-encode both the original config, and the updated config into proto:

```bash
$ curl -X POST --data-binary @config.json http://127.0.0.1:7059/protolator/encode/common.Config > config.pb
$ curl -X POST --data-binary @updated_config.json http://127.0.0.1:7059/protolator/encode/common.Config > updated_config.pb
```

6. send them to the configtxlator service to compute the config update which transitions between the two.

```bash
$ curl -X POST -F original=@config.pb -F updated=@updated_config.pb http://127.0.0.1:7059/configtxlator/compute/update-from-configs -F channel=businesschannel > config_update.pb
```

7. we decode the ConfigUpdate so that we may work with it as text:
```bash
$ curl -X POST --data-binary @config_update.pb http://127.0.0.1:7059/protolator/decode/common.ConfigUpdate > config_update.json
```

8. Then, we wrap it in an envelope message:

```bash
$ echo '{"payload":{"header":{"channel_header":{"channel_id":"businesschannel", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}' > config_update_as_envelope.json
```

9. Next, convert it back into the proto form of a full fledged config transaction:

```bash
$ curl -X POST --data-binary @config_update_as_envelope.json http://127.0.0.1:7059/protolator/encode/common.Envelope > config_update_as_envelope.pb
````

10. Finally, submit the config update transaction to ordering to perform a config update.

```bash
$ CORE_PEER_LOCALMSPID=OrdererMSP
$ CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/users/Admin@example.com/msp

$ peer channel update -o orderer.example.com:7050 -c businesschannel -f config_update_as_envelope.pb --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
$ peer channel update -f config_update_as_envelope.pb -o orderer.example.com:7050 -c businesschannel  # with no-tls
```

### [WIP]Add an organization

1. Execute `configtxgen` to generate `channel.tx`

```bash
$ ORDERER_GENERAL_GENESISPROFILE=SampleDevModSolo #Change this env before start ordering service.
```

```bash
$ docker exec -it fabric-cli bash
$ configtxgen -profile SampleDevModSolo -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID businesschannel
```

2. create channel use channel.tx, then we will get block businesschannel.block

```bash
$ peer channel create -o orderer.example.com:7050 -c businesschannel -f ./channel-artifacts/channel.tx
```

3. Start configtxlator

```bash
$ docker exec -it fabric-cli bash
$ configtxlator start
```

4. In a new window, decoding current genesis block

```bash
$ curl -X POST --data-binary @businesschannel.block http://127.0.0.1:7059/protolator/decode/common.Block > businesschannel.json
```

5. Extract current config

```bash
jq .data.data[0].payload.data.config businesschannel.json > config.json
```

6. generating new config

```bash
jq '. * {"channel_group":{"groups":{"Application":{"groups":{"ExampleOrg": .channel_group.groups.Application.groups.SampleOrg}}}}}'  config.json  |
jq '.channel_group.groups.Application.groups.ExampleOrg.values.MSP.value.config.name = "ExampleOrg"' > update_config.json
```

7. Translate config.json and update_config.json to proto

```bash
curl -X POST --data-binary @config.json http://127.0.0.1:7059/protolator/encode/common.Config > config.pb
curl -X POST --data-binary @update_config.json http://127.0.0.1:7059/protolator/encode/common.Config > update_config.pb
```

8. Computing config update

```bash
curl -X POST -F original=@config.pb -F updated=@update_config.pb http://127.0.0.1:7059/configtxlator/compute/update-from-configs -F channel=businesschannel > config_update.pb
```

9. Decoding config update

```bash
curl -X POST --data-binary @config_update.pb http://127.0.0.1:7059/protolator/decode/common.ConfigUpdate > config_update.json
```

10. Generating config update envelope

```bash
echo '{"payload":{"header":{"channel_header":{"channel_id":"businesschannel", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}' > config_update_in_envelope.json
```

11. Next, convert it back into the proto form of a full fledged config transaction:

```bash
curl -X POST --data-binary @config_update_in_envelope.json http://127.0.0.1:7059/protolator/encode/common.Envelope > config_update_in_envelope.pb
```

12. Sending config update to channel

```bash
$ CORE_PEER_LOCALMSPID=OrdererMSP
$ CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/users/Admin@example.com/msp

$ peer channel update -o orderer.example.com:7050 -c businesschannel -f config_update_in_envelope.pb --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
$ (optional)peer channel update -f config_update_as_envelope.pb -o orderer.example.com:7050 -c businesschannel  # with no-tls
```