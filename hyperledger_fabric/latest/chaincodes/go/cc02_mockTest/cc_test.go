package main

import (
    "strconv"
    "testing"

    "github.com/hyperledger/fabric/core/chaincode/shim"
)

// TestMockShim test the chaincode with MockShim
func TestMockShim(t *testing.T) {
    var Aval int
    var err error

    // Instantiate mockStub using the sample example02 chaincode
    stub := shim.NewMockStub("mockStub", new(SimpleChaincode))
    if stub == nil {
        t.Fatalf("MockStub creation failed")
    }

    // Init with tx_uuid, args
    result := stub.MockInit("000001", [][]byte{[]byte("init"), []byte("a"), []byte("100"), []byte("b"), []byte("200")})
    if result.Status != shim.OK {
        t.Fatalf("Error to Init the chaincode: %+v", result)
    }

    // Query the existing result
    result = stub.MockInvoke("000002", [][]byte{[]byte("query"), []byte("a")})
    if result.Status != shim.OK {
        t.Fatalf("Error to Invoke.query the chaincode: %+v", result)
    }
    Aval, err = strconv.Atoi(string(result.Payload))
	if err != nil {
		t.Errorf("Expecting integer value for query result")
	}
	if Aval != 100 {
		t.Errorf("Value is not equal to expected from query result")
	}

    // Invoke to transfer
    result = stub.MockInvoke("000003", [][]byte{[]byte("invoke"), []byte("a"), []byte("b"), []byte("10")})
    if result.Status != shim.OK {
        t.Fatalf("Error to Invoke.invoke the chaincode: %+v", result)
    }

    // Query the existing result
    result = stub.MockInvoke("000004", [][]byte{[]byte("query"), []byte("a")})
    if result.Status != shim.OK {
        t.Fatalf("Error to Invoke.query the chaincode: %+v", result)
    }
    Aval, err = strconv.Atoi(string(result.Payload))
	if err != nil {
		t.Errorf("Expecting integer value for query result")
	}
	if Aval != 90 {
		t.Errorf("Value is not equal to expected from query result")
	}
}
