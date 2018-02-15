/*
   Oraclize DelegatedMathExample Example
*/


pragma solidity ^0.4.0;
import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";


contract DelegatedMathExample is usingOraclize {
    
    event operationResult(uint _result);
    
    function DelegatedMathExample() {
        oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS); 
        delegateOperation("32", "125");
    }

    function __callback(bytes32 myid, string result, bytes proof) {
        if (msg.sender != oraclize_cbAddress()) throw;
        operationResult(parseInt(result));
    }
    
    function delegateOperation(string _firstOperand, string _secondOperand) payable {

        oraclize_query("computation",["Qmc8jmuT47cPWadF8ZhErGXj7J4VEp5H29knukCGirsN19", _firstOperand, _secondOperand]);
    }
    
    
}
