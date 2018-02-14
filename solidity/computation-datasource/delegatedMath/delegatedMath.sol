/*
   Oraclize DelegatedMathExample Example
*/


pragma solidity ^0.4.0;
import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

contract DelegatedMathExample is usingOraclize {
    
    event operationResult(uint _result);
    
    function DelegatedMathExample() {
        oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS); 
        delegateOperation("32", "125", "+");
    }

    function __callback(bytes32 myid, string result, bytes proof) {
        if (msg.sender != oraclize_cbAddress()) throw;
        operationResult(parseInt(result));
    }
    
    function delegateOperation(string _firstOperand, string _secondOperand, string _operation) payable {

        oraclize_query("computation",["QmQ4iYP5hLut8etC7Fat8EaRcQenhGCUMSjiuo3yWig1Rr", _firstOperand, _secondOperand, "+"]);
    }
    
    
}
