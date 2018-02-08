/*
    Utilizies computation datasource

    Launches an AWS instance which connects to the streamr BTC tweets stream
    via websockets, and then counts the amount of BTC tweets, until the set
    duration, and returns the count
*/

pragma solidity ^0.4.0;

import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

contract StreamrTweetsCounter is usingOraclize {

    uint public btcTweetsLastMinute;

    event newOraclizeQuery(string description);
    event emitResult(string result);


    function StreamrTweetsCounter() payable {
        oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
        update();
    }

    function __callback(bytes32 myid, string result) {
        if (msg.sender != oraclize_cbAddress()) throw;

        btcTweetsLastMinute = parseInt(result);
        emitResult(result);
    }

    function update() payable {
        if (oraclize_getPrice("computation") > this.balance) {
            newOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            newOraclizeQuery("Oraclize query was sent, standing by for the answer...");

            oraclize_query("computation",
                ["QmWFV2UrcUFMFk5R4iTZdusTRsvqohFwHjyXNH1Yu9v3Nm", // the ipfs multihash of archive
                "1"] // duration to run stream in minutes
            );
        }
    }
}
