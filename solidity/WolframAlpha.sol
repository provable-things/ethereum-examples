pragma solidity ^0.5.0;

import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

contract WolframAlpha is usingOraclize {

    string public temperature;

    event LogNewOraclizeQuery(string description);
    event LogNewTemperatureMeasure(string temperature);

    constructor() public {
        update(); // Update on contract creation...
    }

    function __callback(bytes32 myid, string memory result) public {
        require(msg.sender == oraclize_cbAddress());
        temperature = result;
        emit LogNewTemperatureMeasure(temperature);
        // Do something with the temperature measure...
    }

    function update() public payable {
        emit LogNewOraclizeQuery("Oraclize query was sent, standing by for the answer...");
        oraclize_query("WolframAlpha", "temperature in London");
    }
}
