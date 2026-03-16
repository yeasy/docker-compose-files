# Hyperledger Fabric v3.1.4 examples

This directory contains the Fabric `v3.1.4` sample network used by this
repository.

## Tested flow

The verified path uses the Raft network and the Fabric lifecycle commands with
an external chaincode service for `exp02`.

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

The full quick test is still available through:

```bash
HLF_MODE=raft make
```

## Chaincode runtime

`exp02` runs as chaincode-as-a-service instead of the legacy in-peer Docker
build flow.

- `scripts/test_cc_install_host.sh` packages the chaincode on the host.
- `scripts/package_chaincode.py --kind ccaas` writes the package metadata and
  connection information.
- `scripts/start_ccaas_host.sh` builds and starts `exp02-ccaas` through
  `docker-compose-ccaas.yaml`.
- The peer installs the generated package and then continues with approve,
  commit, invoke, and query.

The sample chaincode can run in both modes:

- classic shim mode when `CHAINCODE_ID` and `CHAINCODE_SERVER_ADDRESS` are not
  set
- external service mode when both variables are set

## Notes

- `make stop` removes the sample network with `docker-compose down -v` so each
  rerun starts from a clean ledger state.
- The lifecycle helpers use `--waitForEvent=false` and then poll approval and
  commit state explicitly. This avoids false failures caused by event waiting
  during approval and commit.
- `test_cc_queryapproved` queries sequence `1` explicitly, matching the tested
  lifecycle flow.

## Known limitations

- `DEV_MODE=dev` is intentionally disabled for `v3.1.4`. The old source-mounted
  developer mode is not supported in this setup.
- Legacy `instantiate`, `upgrade`, and `lscc` test targets are intentionally
  disabled. Use the lifecycle targets instead.
- The documented and validated path is the Raft topology in
  `docker-compose-2orgs-4peers-raft.yaml`.

See `raft/README.md` for the Raft quick start.
