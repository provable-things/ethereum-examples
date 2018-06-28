/*
    WolframAlpha example

    This contract sends a temperature measure request to WolframAlpha
*/
pragma solidity ^0.4.0;

import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";


contract WolframAlpha is usingOraclize {

    string public temperature;

    event NewOraclizeQuery(string description);
    event NewTemperatureMeasure(string temperature);

    function WolframAlpha() public {
        update();
    }

    function __callback(bytes32 myid, string result) public {
        if (msg.sender != oraclize_cbAddress()) revert();
        temperature = result;
        NewTemperatureMeasure(temperature);
        // do something with the temperature measure..
    }

    function update() public payable {
        NewOraclizeQuery("Oraclize query was sent, standing by for the answer..");
        oraclize_query("WolframAlpha", "temperature in London");
    }
}