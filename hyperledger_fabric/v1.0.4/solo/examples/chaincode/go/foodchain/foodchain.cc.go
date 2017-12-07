package main

import (
	//"bytes"
	"encoding/json"
	"fmt"
	//"strconv"
	//"strings"
	"time"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	pb "github.com/hyperledger/fabric/protos/peer"
)

//=============================================================================================================================================================================

//																					Structs

//=============================================================================================================================================================================



type SimpleChaincode struct {
}

type user struct {
	
	Firstname  string `json:"firstname"`
	Lastname   string `json:"lastname"`
	userID	   string `json:"userid"`
	DOB        string `json:"dob"`
	Email      string `json:"email"`
	Mobile     string `json:"mobile"`
	Class	   string `json:"class"`
	ObjectType string `json:"docType"`
}

type RawMaterial struct {
	
	RMID 			string `json:"rmid"`
	Item			string `json:"item"`
	Creator  		string `json:"creator"`
	Current_Owner   string `json:"currentowner"`
	ClaimTags       string `json:"claimtags"`
	Location      	string `json:"location"`
	Date     		string `json:"date"`
	CertID	   		string `json:"certid"`
	ObjectType      string `json:"docType"`
	// add quality
}


type FinishedGood struct {
	FPID			string `json:"fpid"`
	Name 			string `json:"name"`
	Creator  		string `json:"creator"`
	Current_Owner   string `json:"currentowner"`
	Ingredients 	string `json:"ingredients"`
	//Previous_Owner  string `json:"previousowner"`
	Certificates	string `json:"certificates"`
	ClaimTags       string `json:"claimtags"`
	Location      	string `json:"location"`
	Date     		string `json:"date"`
	CertID	   		string `json:"certid"`
	ObjectType 		string `json:"docType"`
}

type PurchaseOrder struct{

	PurchaseOrderID	string `json:"purchaseorderid"`
	Customer  		string `json:"customer"`
	Vendor   		string `json:"vendor"`
	ProductID   	string `json:"productid"`
	Price       	string `json:"price"`
	Date        	string `json:"date"`
//	Status          string `json:"status"`
	ObjectType 		string `json:"docType"`
}

type Certificate struct {
	
	CertID 			string `json:"certid"`
	OrgName			string `json:"orgname"`
	Supplier		string `json:"supplier"`
	Status  		string `json:"status"`
	Date_effective  	string `json:"dateeffective"`
	Certifier       	string `json:"certifier"`
	ProductList		string `json:"productlist"`
	OpDetails     		string `json:"opdetails"`
	Location      		string `json:"location"`
	ExpiryDate	   	string `json:"expdate"`
	ObjectType      	string `json:"docType"`
}


// =============================================================================================================================================================

// 																					MAIN FUNCTIONS

// ==============================================================================================================================================================
func main() {
	err := shim.Start(new(SimpleChaincode))
	if err != nil {
		fmt.Printf("Error starting Simple chaincode: %s", err)
	}
}

// Init initializes chaincode
// ===========================
func (t *SimpleChaincode) Init(stub shim.ChaincodeStubInterface) pb.Response {
	var err error
	err = stub.PutState("status", []byte("Blockchain online")) //write the variable into the chaincode state
	if err != nil {
		return shim.Error(err.Error())
	}
	
	return shim.Success(nil)
}

// Invoke - Our entry point for Invocations
// ========================================
func (t *SimpleChaincode) Invoke(stub shim.ChaincodeStubInterface) pb.Response {
	function, args := stub.GetFunctionAndParameters()
	fmt.Println("invoke is running " + function)

	// Handle different functions
	if function == "Register" { //create a new user
		return t.Register(stub, args)
	} else if function == "RegisterRM" { 
		return t.RegisterRM(stub, args) 
	} else if function == "RegisterFP" { 
		return t.RegisterFP(stub, args) 
	} else if function == "makePurchaseOrder" { 
		return t.makePurchaseOrder(stub, args) 
	} else if function == "replyPurchaseOrder" { 
		return t.replyPurchaseOrder(stub, args) 
	} else if function == "transferRM" { 
		return t.transferRM(stub, args) 
	} else if function == "transferFP" { 
		return t.transferFP(stub, args) 
	} else if function == "awardCert" { 
		return t.awardCert(stub, args) 
	} else if function == "requestCert" { 
		return t.requestCert(stub, args) 
	} else if function == "read" { 
		return t.read(stub, args) 
	} else if function == "getHistory" { 
		return t.getHistory(stub, args) 
	} else if function == "modifyCert" { 
		return t.modifyCert(stub, args) 
	} else if function == "getHistoryFG" { 
		return t.getHistoryFG(stub, args) 
	}
	fmt.Println("invoke did not find func: " + function) //error
	return shim.Error("Received unknown function invocation")
}


//============================================================================================================================================================================

//																				REGISTRATION CODE BELOW

//=============================================================================================================================================================================



func (t *SimpleChaincode) Register(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var err error

//	Firstname  string `json:"firstname"`		0
//	Lastname   string `json:"lastname"`			1
//	userID	   string `json:"userid"`			2
//	DOB        string `json:"dob"`				3
//	Email      string `json:"email"`			4
//	Mobile     string `json:"mobile"`			5
//	Class	   string `json:"class"`			6
	
	
	if len(args) != 7 {
		return shim.Error("Incorrect number of arguments. Expecting 7")
	}

	// ==== Input sanitation ====
	
	fname := args[0]
	lname := args[1]
	uid := args[2]
	userdob := args[3]
	useremail := args[4]
	usermobile := args[5]
	userclass := args[6]

	
	
	// ==== Check if user already exists ====
	fnameAsBytes, err := stub.GetState(uid)		//Change this to uid not fname
	if err != nil {
		return shim.Error("Failed to get user: " + err.Error())
	} else if fnameAsBytes != nil {
		fmt.Println("This user already exists: " + fname)
		return shim.Error("This user already exists: " + fname)
	}

	// ==== Create user object and marshal to JSON ====
	objectType := "user"
	user := &user{fname, lname, uid, userdob, useremail, usermobile, userclass, objectType}
	userJSONasBytes, err := json.Marshal(user)
	if err != nil {
		return shim.Error(err.Error())
	}
	

	// === Save user to state ===
	err = stub.PutState(uid, userJSONasBytes)
	if err != nil {
		return shim.Error(err.Error())
	}
	//this should be uid based range query, needs to be tested
	//  Index
	indexName := "uid~fname"
	uidIndexKey, err := stub.CreateCompositeKey(indexName, []string{user.userID, user.Firstname})
	if err != nil {
		return shim.Error(err.Error())
	}
	//  Save index entry to state. Only the key name is needed, no need to store a duplicate copy of the user.
	//  Note - passing a 'nil' value will effectively delete the key from state, therefore we pass null character as value
	value := []byte{0x00}
	stub.PutState(uidIndexKey, value)

	// ==== user saved and indexed. Return success ====
	fmt.Println("- end init user")
	return shim.Success(nil)
}


func (t *SimpleChaincode) RegisterRM(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var err error

//	RMID 			string `json:"rmid"`					0
//  Item 			string `json:"item"`					1
//	Creator  		string `json:"creator"`					2
//	Current_Owner   string `json:"currentowner"`			3
//	ClaimTags       string `json:"claimtags"`				4
//	Location      	string `json:"location"`				5
//	Date     		string `json:"date"`					6
//	CertID	   		string `json:"certid"`					7
//	ObjectType      string `json:"docType"`					8
	
	
	

	// ==== Input sanitation ====
	
	rawid := args[0]
	item := args[1]
	originalcreator := args[2]
	cowner := args[3]
	claimtags := args[4]
	loc := args[5]
	dates := args[6]
	userclass := args[7]
	

	
	// ==== Check if RM already exists ====
	rawidAsBytes, err := stub.GetState(rawid)		
	if err != nil {
		return shim.Error("Failed to get user: " + err.Error())
	} else if rawidAsBytes != nil {
		fmt.Println("This user already exists: " + rawid)
		return shim.Error("This user already exists: " + rawid)
	}

	// ==== Create RM object and marshal to JSON ====
	objectType := "RawMaterial"
	RawMaterial := &RawMaterial{rawid, item, originalcreator, cowner, claimtags, loc, dates, userclass, objectType}
	RawMaterialJSONasBytes, err := json.Marshal(RawMaterial)
	if err != nil {
		return shim.Error(err.Error())
	}
	

	// === Save RM to state ===
	err = stub.PutState(rawid, RawMaterialJSONasBytes)
	if err != nil {
		return shim.Error(err.Error())
	}

	//  Index 
	indexName := "rawid~cowner"
	rawidIndexKey, err := stub.CreateCompositeKey(indexName, []string{RawMaterial.RMID, RawMaterial.Current_Owner})
	if err != nil {
		return shim.Error(err.Error())
	}
	//  Save index entry to state. Only the key name is needed, no need to store a duplicate copy of the user.
	//  Note - passing a 'nil' value will effectively delete the key from state, therefore we pass null character as value
	value := []byte{0x00}
	stub.PutState(rawidIndexKey, value)

	// ==== RM saved and indexed. Return success ====
	fmt.Println("- end init user")
	return shim.Success(nil)
}


func (t *SimpleChaincode) RegisterFP(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var err error

//	ObjectType 		string `json:"docType"`					0
//	FPID			string `json:"fpid"`					1	
//	Name 			string `json:"name"`					2
//	Creator  		string `json:"creator"`					3
//	Current_Owner   string `json:"currentowner"`			4
//	Ingredients 	string `json:"ingredients"`				5
////Previous_Owner  string `json:"previousowner"`			6
//	Certificates	string `json:"certificates"`			7
//	ClaimTags       string `json:"claimtags"`				8
//	Location      	string `json:"location"`				9	
//	Date     		string `json:"date"`					10
//	CertID	   		string `json:"certid"`					11
	
	
	

	// ==== Input sanitation ====
	
	fpid_i := args[0]
	name_i := args[1]
	originalcreator_i := args[2]
	cowner_i := args[3]
	ingredients_i := args[4]
	certificates_i := args[5]
	claimtags_i := args[6]
	loc_i := args[7]
	dates_i := args[8]
	certid_i := args[9]
	

	
	// ==== Check if FP already exists ====
	fpid_iAsBytes, err := stub.GetState(fpid_i)		
	if err != nil {
		return shim.Error("Failed to get user: " + err.Error())
	} else if fpid_iAsBytes != nil {
		fmt.Println("This user already exists: " + fpid_i)
		return shim.Error("This user already exists: " + fpid_i)
	}

	// ==== Create object and marshal to JSON ====
	objectType := "FinishedGood"
	FinishedGood := &FinishedGood{fpid_i, name_i, originalcreator_i, cowner_i, ingredients_i, certificates_i, claimtags_i, loc_i, dates_i, certid_i, objectType}
	FinishedGoodJSONasBytes, err := json.Marshal(FinishedGood)
	if err != nil {
		return shim.Error(err.Error())
	}
	

	// === Save FP to state ===
	err = stub.PutState(fpid_i, FinishedGoodJSONasBytes)
	if err != nil {
		return shim.Error(err.Error())
	}

	//Index
	indexName := "fpid_i~cowner"
	fpiIndexKey, err := stub.CreateCompositeKey(indexName, []string{FinishedGood.FPID, FinishedGood.Current_Owner})
	if err != nil {
		return shim.Error(err.Error())
	}
	//  Save index entry to state. Only the key name is needed, no need to store a duplicate copy of the user.
	//  Note - passing a 'nil' value will effectively delete the key from state, therefore we pass null character as value
	value := []byte{0x00}
	stub.PutState(fpiIndexKey, value)

	// ==== FP saved and indexed. Return success ====
	fmt.Println("- end init user")
	return shim.Success(nil)
}

//=============================================================================================================================================================================

//																				Purchase Orders

//=============================================================================================================================================================================

func (t *SimpleChaincode) makePurchaseOrder(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var err error

//	PurchaseOrderID	string `json:"purchaseorderid"`		0
//	Customer  		string `json:"customer"`			1
//	Vendor   		string `json:"vendor"`				2
//	ProductID   	string `json:"productid"`			3
//	Price       	string `json:"price"`				4
//	Date        	string `json:"date"`				5
//  Status          string `json:"status"`              Pending
//	ObjectType 		string `json:"docType"`				PurchaseOrder
	
	// ==== Input sanitation ====
	
	purchid := args[0]
	cust := args[1]
	vend := args[2]
	prodid := args[3]
	price:= args[4]
	dat := args[5]
	//stat := "Pending"
	

	
	
	// ==== Check if order already exists ====
	purchAsBytes, err := stub.GetState(purchid)		
	if err != nil {
		return shim.Error("Failed to get product: " + err.Error())
	} else if purchAsBytes != nil {
		fmt.Println("This product already exists: " + purchid)
		return shim.Error("This product already exists: " + purchid)
	}

	// ==== Create object and marshal to JSON ====
	objectType := "PurchaseOrder"
	PurchaseOrder := &PurchaseOrder{purchid, cust, vend, prodid, price, dat, objectType}
	prodJSONasBytes, err := json.Marshal(PurchaseOrder)
	if err != nil {
		return shim.Error(err.Error())
	}
	

	// === Save order to state ===
	err = stub.PutState(purchid, prodJSONasBytes)
	if err != nil {
		return shim.Error(err.Error())
	}

	// ==== order saved and NOT indexed. Return success ====
	fmt.Println("- end init user")
	return shim.Success(nil)
}

func (t *SimpleChaincode) replyPurchaseOrder(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var err error

	var key, value string
	
	
	var a = time.Now()
	var b = a.Format("20060102150405") 
	key = args[0] 
	var body = args[2] //this will be the yes or no
	value = args[1] + "-" + b +"-"+  key + " " + body


	err = stub.PutState(key, []byte(value)) //write the variable into the chaincode state
	if err != nil {
		return shim.Error(err.Error())
	}
	
	return shim.Success(nil)
}

//===========================================================================================================================================================================

//																				Transferring

//===========================================================================================================================================================================



func (t *SimpleChaincode) transferRM(stub shim.ChaincodeStubInterface, args []string) pb.Response {

	//   0       1
	// "name", "bob"
	if len(args) < 2 {
		return shim.Error("Incorrect number of arguments. Expecting 2")
	}

	prodid := args[0]
	newOwner := args[1]
	newLoc := args[2]
	newDate := args[3]
	

	assetAsBytes, err := stub.GetState(prodid)
	if err != nil {
		return shim.Error("Failed to get asset:" + err.Error())
	} else if assetAsBytes == nil {
		return shim.Error("Assest does not exist")
	}

	assetToTransfer := RawMaterial{}
	err = json.Unmarshal(assetAsBytes, &assetToTransfer) //unmarshal it aka JSON.parse()
	if err != nil {
		return shim.Error(err.Error())
	}
	assetToTransfer.Current_Owner = newOwner //change the owner
	assetToTransfer.Location = newLoc
	assetToTransfer.Date = newDate
	

	assetJSONasBytes, _ := json.Marshal(assetToTransfer)
	err = stub.PutState(prodid, assetJSONasBytes) //rewrite the asset
	if err != nil {
		return shim.Error(err.Error())
	}

	fmt.Println("- end transferRM (success)")
	return shim.Success(nil)
}

func (t *SimpleChaincode) transferFP(stub shim.ChaincodeStubInterface, args []string) pb.Response {

	//   0       1
	// "name", "bob"
	if len(args) < 2 {
		return shim.Error("Incorrect number of arguments. Expecting 2")
	}

	prodid := args[0]
	newOwner := args[1]
	newLoc := args[2]
	newDate := args[3]
	

	assetAsBytes, err := stub.GetState(prodid)
	if err != nil {
		return shim.Error("Failed to get asset:" + err.Error())
	} else if assetAsBytes == nil {
		return shim.Error("Assest does not exist")
	}

	assetToTransfer := FinishedGood{}
	err = json.Unmarshal(assetAsBytes, &assetToTransfer) //unmarshal it aka JSON.parse()
	if err != nil {
		return shim.Error(err.Error())
	}
	assetToTransfer.Current_Owner = newOwner //change the owner
	assetToTransfer.Location = newLoc
	assetToTransfer.Date = newDate
	

	assetJSONasBytes, _ := json.Marshal(assetToTransfer)
	err = stub.PutState(prodid, assetJSONasBytes) //rewrite the asset
	if err != nil {
		return shim.Error(err.Error())
	}

	fmt.Println("- end transferRM (success)")
	return shim.Success(nil)
}


//===========================================================================================================================================================================

//																			Certifying

//===========================================================================================================================================================================

func (t *SimpleChaincode) awardCert(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var err error

//	CertID 			string `json:"certid"`					0
//	OrgName			string `json:"orgname"`					1
//  	Supplier        	string `json:"supplier"`				2
//	Status  		string `json:"status"`					3
//	Date_effective  	string `json:"dateeffective"`				4
//	Certifier       	string `json:"certifier"`				5
//	ProductList		string `json:"productlist"`				6
//	OpDetails     		string `json:"opdetails"`				7
//	Location      		string `json:"location"`				8
//	ExpiryDate	   	string `json:"expdate"`					9
//	ObjectType      	string `json:"docType"`					10
	
	
	

	// ==== Input sanitation ====
	
	certid := args[0]
	oname := args[1]
	supplier := args[2]
	stat := args[3]
	dateeff := args[4]
	certifierorg := args[5]
	prodlist := args[6]
	opdet := args[7]
	loc := args[8]
	expdat := args[9]
	

	
	// ==== Check if cert already exists ====
	awardAsBytes, err := stub.GetState(certid)		
	if err != nil {
		return shim.Error("Failed to get cert: " + err.Error())
	} else if awardAsBytes != nil {
		fmt.Println("This cert already exists: " + certid)
		return shim.Error("This cert already exists: " + certid)
	}

	// ==== Create object and marshal to JSON ====
	objectType := "Certificate"
	Certificate := &Certificate{certid, oname, supplier, stat, dateeff, certifierorg, prodlist, opdet, loc, expdat, objectType}

	CertJSONasBytes, err := json.Marshal(Certificate)
	if err != nil {
		return shim.Error(err.Error())
	}
	

	// === Save certificate to state ===
	err = stub.PutState(certid, CertJSONasBytes)
	if err != nil {
		return shim.Error(err.Error())
	}

	// ==== certificate saved and NOT indexed. Return success ====
	fmt.Println("- end init cert")
	return shim.Success(nil)
}


func (t *SimpleChaincode) requestCert(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var err error
	var key, value string
	//arg 0 is the certificate request id which will be UUID generated but for now just input
	//arg 1 is the suppliers id who is requesting the certificate
	//arg 2 is the name of the certificate
	//arg 3 is the products
	//arg 4 is the location  

	var a = time.Now()
	var b = a.Format("20060102150405") 
	key = args[0]
	var suppid = args[1]
	var name = args[2] 
	var product = args[3]
	var location = args[4] 
	value = key + "-" + b + " " + suppid + " " + name + " " + product + " " + location 


	err = stub.PutState(key, []byte(value)) //write the variable into the chaincode state
	if err != nil {
		return shim.Error(err.Error())
	}
	
	return shim.Success(nil)
}
//
// This function should be used to revoke certificates but because of its open input nature can be more flexible and be used for whatever really
//
func (t *SimpleChaincode) modifyCert(stub shim.ChaincodeStubInterface, args []string) pb.Response {

	//    0       	   1
	// "certid", "new status"
	if len(args) < 2 {
		return shim.Error("Incorrect number of arguments. Expecting 2")
	}

	certid := args[0]		// assigning first input to certid
	newStatus := args[1]	// assigning second input to the new status of the certificate
	

	certAsBytes, err := stub.GetState(certid) //retrieving the certificate from the blockchain using the getstate function
	if err != nil {
		return shim.Error("Failed to get certificate:" + err.Error())
	} else if certAsBytes == nil {
		return shim.Error("Certificate does not exist")
	}

	certToModify := Certificate{}
	err = json.Unmarshal(certAsBytes, &certToModify) //unmarshal it aka JSON.parse()
	if err != nil {
		return shim.Error(err.Error())
	}
	certToModify.Status = newStatus //change the status

	certJSONasBytes, _ := json.Marshal(certToModify)
	err = stub.PutState(certid, certJSONasBytes) //rewrite the asset
	if err != nil {
		return shim.Error(err.Error())
	}

	fmt.Println("- end revokeCert (success)")
	return shim.Success(nil)
}

//===========================================================================================================================================================================

//																				Reading

//===========================================================================================================================================================================


func (t *SimpleChaincode) read(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var A string // Entities
	var err error

	A = args[0]

	// Get the state from the ledger
	Avalbytes, err := stub.GetState(A)
	if err != nil {
		jsonResp := "{\"Error\":\"Failed to get state for " + A + "\"}"
		return shim.Error(jsonResp)
	}



	//jsonResp := "{\"Name\":\"" + A + "\",\"Amount\":\"" + string(Avalbytes) + "\"}"
	//fmt.Printf("Query Response:%s\n", jsonResp)
	return shim.Success(Avalbytes)
}

/*
func (t *SimpleChaincode) queryRMByUID(stub shim.ChaincodeStubInterface, args []string) pb.Response {

	//   0
	// "bob"
	if len(args) < 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	owner := args[0]

	queryString := fmt.Sprintf("{\"selector\":{\"docType\":\"RawMaterial\",\"owner\":\"%s\"}}", owner)

	queryResults, err := getQueryResultForQueryString(stub, queryString)
	if err != nil {
		return shim.Error(err.Error())
	}
	return shim.Success(queryResults)
}


func getQueryResultForQueryString(stub shim.ChaincodeStubInterface, queryString string) ([]byte, error) {

	fmt.Printf("- getQueryResultForQueryString queryString:\n%s\n", queryString)

	resultsIterator, err := stub.GetQueryResult(queryString)
	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()

	// buffer is a JSON array containing QueryRecords
	var buffer bytes.Buffer
	buffer.WriteString("[")

	bArrayMemberAlreadyWritten := false
	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			return nil, err
		}
		// Add a comma before array members, suppress it for the first array member
		if bArrayMemberAlreadyWritten == true {
			buffer.WriteString(",")
		}
		buffer.WriteString("{\"Key\":")
		buffer.WriteString("\"")
		buffer.WriteString(queryResponse.Key)
		buffer.WriteString("\"")

		buffer.WriteString(", \"Record\":")
		// Record is a JSON object, so we write as-is
		buffer.WriteString(string(queryResponse.Value))
		buffer.WriteString("}")
		bArrayMemberAlreadyWritten = true
	}
	buffer.WriteString("]")

	fmt.Printf("- getQueryResultForQueryString queryResult:\n%s\n", buffer.String())

	return buffer.Bytes(), nil
}
*/


func (t *SimpleChaincode) getHistory(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	type AuditHistory struct {
		TxId    string   `json:"txId"`
		Value   RawMaterial   `json:"value"`
	}
	var history []AuditHistory;
	var rawmaterial RawMaterial

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	RMId := args[0]
	fmt.Printf("- start getHistoryForMarble: %s\n", RMId)

	// Get History
	resultsIterator, err := stub.GetHistoryForKey(RMId)
	if err != nil {
		return shim.Error(err.Error())
	}
	defer resultsIterator.Close()

	for resultsIterator.HasNext() {
		historyData, err := resultsIterator.Next()
		if err != nil {
			return shim.Error(err.Error())
		}

		var tx AuditHistory
		tx.TxId = historyData.TxId                     //copy transaction id over
		json.Unmarshal(historyData.Value, &rawmaterial)     //un stringify it aka JSON.parse()
		if historyData.Value == nil {                  //marble has been deleted
			var emptyRM RawMaterial
			tx.Value = emptyRM                 //copy nil marble
		} else {
			json.Unmarshal(historyData.Value, &rawmaterial) //un stringify it aka JSON.parse()
			tx.Value = rawmaterial                  //copy marble over
		}
		history = append(history, tx)              //add this tx to the list
	}
	fmt.Printf("- getHistoryForMarble returning:\n%s", history)

	//change to array of bytes
	historyAsBytes, _ := json.Marshal(history)     //convert to array of bytes
	return shim.Success(historyAsBytes)
}

func (t *SimpleChaincode) getHistoryFG(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	type AuditHistory struct {
		TxId    string   `json:"txId"`
		Value   FinishedGood   `json:"value"`
	}
	var history []AuditHistory;
	var finishedgood FinishedGood

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	FGId := args[0]
	fmt.Printf("- start getHistoryForMarble: %s\n", FGId)

	// Get History
	resultsIterator, err := stub.GetHistoryForKey(FGId)
	if err != nil {
		return shim.Error(err.Error())
	}
	defer resultsIterator.Close()

	for resultsIterator.HasNext() {
		historyData, err := resultsIterator.Next()
		if err != nil {
			return shim.Error(err.Error())
		}

		var tx AuditHistory
		tx.TxId = historyData.TxId                     //copy transaction id over
		json.Unmarshal(historyData.Value, &finishedgood)     //un stringify it aka JSON.parse()
		if historyData.Value == nil {                  //marble has been deleted
			var emptyFG FinishedGood
			tx.Value = emptyFG                 //copy nil marble
		} else {
			json.Unmarshal(historyData.Value, &finishedgood) //un stringify it aka JSON.parse()
			tx.Value = finishedgood                  //copy marble over
		}
		history = append(history, tx)              //add this tx to the list
	}
	fmt.Printf("- getHistoryForMarble returning:\n%s", history)

	//change to array of bytes
	historyAsBytes, _ := json.Marshal(history)     //convert to array of bytes
	return shim.Success(historyAsBytes)
}
