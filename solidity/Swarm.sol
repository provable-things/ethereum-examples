/*
   Swarm example
*/

pragma solidity ^0.4.25;
import "https://raw.githubusercontent.com/oraclize/ethereum-api/master/oraclizeAPI_0.4.25.sol";

contract Swarm is usingOraclize {
    
    string public swarmContent;
    
    event newOraclizeQuery(string _description);
    event newSwarmContent(string _swarmContent);

    constructor() public payable {
        update();
    }
    
    function __callback(bytes32 _myid, string _result) {
        if (msg.sender != oraclize_cbAddress()) revert();
        swarmContent = _result;
        emit newSwarmContent(_result);
        // Do something with the Swarm content
    }
    
    function update() public payable {
        emit newOraclizeQuery("Oraclize query was sent, standing by for the answer...");
        oraclize_query("swarm", "1dad37bcc272aa31d45128992be575820bececb13dd42c4cc87e4b6269067464");
    }
    
} 
