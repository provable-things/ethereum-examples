pragma solidity ^0.4.25;

import "./oraclizeAPI.sol";

contract BitcoinBalanceExample is usingOraclize {
    
    uint256 public balance;

    event LogBitcoinAddressBalance(uint _balance);
    
    constructor() {
        getBalance("3D2oetdNuZUqQHPJmcMDDHYoqkyNVsFk9r");
    }

    function __callback(bytes32 myid, string result, bytes proof) public {
        require(msg.sender == oraclize_cbAddress());
        balance = parseInt(result, 8);
        emit LogBitcoinAddressBalance(balance);
    }
    
    function getBalance(string _bitcoinAddress) public payable {
        oraclize_query("computation",["QmaMFiHXSqCFKkGPbWZh5zKmM827GWNpk9Y1EYhoLfwdHq", _bitcoinAddress]);
    }
}
