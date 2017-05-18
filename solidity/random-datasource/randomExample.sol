/*
   Oraclize random-datasource example

   This contract uses the random-datasource to securely generate off-chain N random bytes
*/

pragma solidity ^0.4.11;

import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

contract RandomExample is usingOraclize {
    
    event newRandomNumber(bytes);

    function RandomExample() {
        oraclize_setProof(proofType_Ledger); // sets the Ledger authenticity proof in the constructor
        update(); // let's ask for N random bytes immediately when the contract is created!
    }
    
    // the callback function is called by Oraclize when the result is ready
    // the oraclize_randomDS_proofVerify modifier prevents an invalid proof to execute this function code:
    // the proof validity is fully verified on-chain
    function __callback(bytes32 _queryId, string _result, bytes _proof) oraclize_randomDS_proofVerify(_queryId, _result, _proof)
    { 
        // if we reach this point successfully, it means that the attached authenticity proof has passed!
        if (msg.sender != oraclize_cbAddress()) throw;
        
        newRandomNumber(bytes(_result));
        // now that we know the random number was safely generate, let's do something with the random number..
    }
    
    function update() payable {
        uint N = 7; // number of random bytes we want the datasource to return
        uint delay = 0; // number of seconds to wait before the execution takes place
        uint callbackGas = 200000; // amount of gas we want Oraclize to set for the callback function
        bytes32 queryId = oraclize_newRandomDSQuery(delay, N, callbackGas); // this function internally generates the correct oraclize_query and returns its queryId
    }
    
}
