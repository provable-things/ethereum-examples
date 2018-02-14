//Oraclize Paypal Example

pragma solidity ^0.4.0;
import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

contract PaypalExample is usingOraclize {

    event PaymentResult(string payment_info);
    
    function PaypalExample() {
        oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS); 
        createPayment("3","5");
    }

    function __callback(bytes32 myid, string result, bytes proof) {
        if (msg.sender != oraclize_cbAddress()) throw;
        PaymentResult(result);
        
    }
    
    function createPayment(string _unitPrice, string _numberUnits) payable {
        // This example will require a newly generate hookb.in, the following
	// is just a placeholder
	string memory ipFetcher = "https://hookb.in/Zm8d62bn";
        oraclize_query("computation",["QmZsVU2hsHYoETeKijxRq798qVm5RwbwoVNt2HcpTSgunn", _unitPrice,_numberUnits, "USD", ipFetcher]);
    }
    
}

