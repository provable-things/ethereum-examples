/*
    WolframAlpha example

    This contract sends a temperature measurement request to WolframAlpha
*/
pragma solidity ^0.4.25;
import "https://raw.githubusercontent.com/oraclize/ethereum-api/master/oraclizeAPI_0.4.25.sol";

contract WolframAlpha is usingOraclize {

    string public temperature;

    event NewOraclizeQuery(string _description);
    event NewTemperatureMeasure(string _temperature);

    constructor() public payable {
        update();
    }

    function __callback(bytes32 _myid, string _result) public {
        if (msg.sender != oraclize_cbAddress()) revert();
        temperature = _result;
        emit NewTemperatureMeasure(temperature);
        // Do something with the temperature measurement
    }

    function update() public payable {
        emit NewOraclizeQuery("Oraclize query was sent, standing by for the answer...");
        oraclize_query("WolframAlpha", "temperature in London");
    }
}
