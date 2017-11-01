## Start a network base on solo

### Quick testing with solo
```bash
$ KAFKA_ENABLED=false make
```
When the fabric-network fully started, it takes about 30~60s to finish all the test. 

## Generate crypto-config and channel-artifacts

```bash
$ make gen_e2e
```
