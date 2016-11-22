/*
   Simple Alarm code.

   This contract will be called back automatically 1 day after its birth
*/

pragma solidity ^0.4.0;
import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

contract Alarm is usingOraclize {

    function Alarm() {
       oraclize_query(1*day, "URL", "");
    }

    function __callback(bytes32 myid, string result) {
        if (msg.sender != oraclize_cbAddress()) throw;

    }

} 
