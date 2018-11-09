pragma solidity ^0.4.25;

import "./oraclizeAPI.sol";

contract DelegatedMath is usingOraclize {
    
    event LogOperationResult(uint result);
    
    constructor() public {
        oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS); 
        delegateOperation("32", "125");
    }

    function __callback(bytes32 myid, string result, bytes proof) public {
        require(msg.sender == oraclize_cbAddress());
        emit LogOperationResult(parseInt(result));
    }
    
    function delegateOperation(string firstOperand, string secondOperand) public payable {
        oraclize_query("computation",["Qmc8jmuT47cPWadF8ZhErGXj7J4VEp5H29knukCGirsN19", firstOperand, secondOperand]);
    }
}
