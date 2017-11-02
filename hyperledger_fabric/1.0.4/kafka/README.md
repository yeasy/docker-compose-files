## Start a network base on kafka

### Quick testing with kafka
```bash
$ KAFKA_ENABLED=true make
```
When the fabric-network fully started, it takes about 30~60s to finish all the test. 

## Generate crypto-config and channel-artifacts

```bash
$ make gen_kafka
```
