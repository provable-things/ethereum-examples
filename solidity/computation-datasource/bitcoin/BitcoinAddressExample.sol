/*
   Oraclize Bitcoin Example
*/


pragma solidity ^0.4.0;
import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

contract BitcoinAddressExample is usingOraclize {
    
    // Address balance in Satoshis
    uint256 public balance;

    event BitcoinAddressBalance(uint _balance);
    
    function BitcoinAddressExample() {
        oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS); 
        getBalance("3D2oetdNuZUqQHPJmcMDDHYoqkyNVsFk9r");
    }

    function __callback(bytes32 myid, string result, bytes proof) {
        if (msg.sender != oraclize_cbAddress()) throw;
        balance = parseInt(result, 8);
        BitcoinAddressBalance(balance);
    }
    
    function getBalance(string _bitcoinAddress) payable {
        oraclize_query("computation",["QmaMFiHXSqCFKkGPbWZh5zKmM827GWNpk9Y1EYhoLfwdHq", _bitcoinAddress]);
    }
    
}
