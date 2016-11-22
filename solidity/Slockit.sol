/*
   Example integration with a Slockit device.

   The contract automatically checks for a rainy weather every minute
   and closes something (a window?) if needed.
*/

pragma solidity ^0.4.0;
import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

contract Etherlock {
    function open();
    function close();
}

contract DoorLock is usingOraclize {
    address slockAddress = 0x87bb217883541a312fac2977c2a744219963586f;
    
    function DoorLock(){
        checkWeather();
    }

    function __callback(bytes32 myid, string result) {
        if (msg.sender != oraclize_cbAddress()) throw;
        if (indexOf(result, "rain") > -1)
            Etherlock(slockAddress).close();
        else
            checkWeather();
    }
    
    function checkWeather() payable {
        oraclize_query(60, "WolframAlpha", "weather conditions in London");
    }
    
}   
