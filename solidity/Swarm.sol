/*
   swarm example
*/


pragma solidity ^0.4.0;
import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

contract swarmExample is usingOraclize {
    
    string public swarmContent;
    
    event newOraclizeQuery(string description);
    event newSwarmContent(string swarmContent);

    function swarmExample() {
        update();
    }
    
    function __callback(bytes32 myid, string result) {
        if (msg.sender != oraclize_cbAddress()) throw;
        swarmContent = result;
        newSwarmContent(result);
        // do something with the swarm content..
    }
    
    function update() payable {
        newOraclizeQuery("Oraclize query was sent, standing by for the answer..");
        oraclize_query("swarm", "1dad37bcc272aa31d45128992be575820bececb13dd42c4cc87e4b6269067464");
    }
    
} 
