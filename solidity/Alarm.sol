/*
   Simple Alarm code.

   This contract will be called back automatically 1 day after its birth
*/

import "dev.oraclize.it/api.sol";

contract Alarm is usingOraclize {

    function Alarm() {
       oraclize_query(1*day, "URL", "");
    }

    function __callback(bytes32 myid, string result) {
        if (msg.sender != oraclize_cbAddress()) throw;

    }

} 
