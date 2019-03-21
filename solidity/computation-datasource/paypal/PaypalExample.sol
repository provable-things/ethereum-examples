pragma solidity >= 0.5.0 < 0.6.0;

import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

contract PaypalExample is usingOraclize {

    event LogPaymentRe(string payment_info);

    constructor() public {
        oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
        createPayment("3","5");
    }

    function __callback(bytes32 myid, string memory result, bytes memory proof) public {
        require(msg.sender == oraclize_cbAddress());
        emit LogPaymentResult(result);
    }

    function createPayment(string memory _unitPrice, string memory _numberUnits) public payable {
    // This example will require a newly generate hookb.in, the following
	// is just a placeholder
	string memory ipFetcher = "https://hookb.in/Zm8d62bn";
        oraclize_query("computation",["QmZsVU2hsHYoETeKijxRq798qVm5RwbwoVNt2HcpTSgunn", _unitPrice,_numberUnits, "USD", ipFetcher]);
    }

}

