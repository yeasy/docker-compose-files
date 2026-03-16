## Start a network base on raft

### Quick testing

```bash
$ HLF_MODE=raft make
```
When the fabric network fully starts, it takes about 30~60s to finish the
sample tests.

This example uses the Fabric lifecycle flow for chaincode management. Legacy
`instantiate`, `upgrade`, `lscc`, and source-mounted `DEV_MODE=dev` workflows
are intentionally disabled for the `v3.1.4` setup.

### Verified lifecycle sequence

Run the following commands from `hyperledger_fabric/v3.1.4`:

```bash
make stop clean
make start
make channel_test
make update_anchors
make test_cc_install
make test_cc_queryinstalled
make test_cc_approveformyorg
make test_cc_queryapproved
make test_cc_checkcommitreadiness
make test_cc_commit
make test_cc_querycommitted
make test_cc_invoke_query
```

The tested chaincode path uses the external `exp02-ccaas` service declared in
`docker-compose-ccaas.yaml`.

See `../README.md` for the full `v3.1.4` notes and known limitations.

### External chaincode flow

The `v3.1.4` example installs `chaincode_example02` through CCAAS instead of
letting peers build chaincode containers through the Docker socket.

`make test_cc_install` now performs these steps:

```bash
python3 scripts/package_chaincode.py \
  --source chaincodes/go/chaincode_example02 \
  --kind ccaas \
  --connection-address exp02-ccaas:9999 \
  --label exp02 \
  --output scripts/exp02.tar.gz

bash scripts/start_ccaas_host.sh exp02 scripts/exp02.tar.gz exp02-ccaas 9999
```

The external chaincode service is defined in `docker-compose-ccaas.yaml` and
joins the shared `hlf_net` bridge network so peers can resolve `exp02-ccaas`
reliably during install and invoke tests.

### Verified Fabric 3 lifecycle

The validated command sequence for this example is:

```bash
make stop clean
make start
make channel_test
make update_anchors
make test_cc_install
make test_cc_queryinstalled
make test_cc_approveformyorg
make test_cc_queryapproved
make test_cc_checkcommitreadiness
make test_cc_commit
make test_cc_querycommitted
make test_cc_invoke_query
```

`approveformyorg` and `commit` use explicit polling instead of relying on
Fabric CLI `waitForEvent`, which proved unreliable with this test environment.
