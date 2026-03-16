# Debug Chaincode with MockShim
Baohua Yang, 2019-01-17

The package will demonstrate how to debug the chaincode with the MockShim lib.

This way is more efficient and quick to debug locally without any fabric network setup.

## Usage

Unzip the package and enter the package path, then run

```bash
# Regular testing should return OK
$ go test .

# Debug with more logs output
$ go test -v .
```

## Files

* chaincode_example02.go: example02 chaincode from HLF repo;
* cc_test.go: test code to verify the example02 chaincode logic.
