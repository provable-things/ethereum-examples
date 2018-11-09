pragma solidity ^0.4.25;

import "./oraclizeAPI.sol";

contract StreamrTweetsCounter is usingOraclize {

    uint public numberOfTweets;

    event LogResult(string result);
    event LogNewOraclizeQuery(string description);

    constructor() public {
        update(); // First check at contract creation... 
    }

    function __callback(bytes32 myid, string result) public {
        require(msg.sender == oraclize_cbAddress());
        numberOfTweets = parseInt(result);
        emit LogResult(result);
    }

    function update() payable {
        if (oraclize_getPrice("computation") > this.balance) {
            emit LogNewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            emit LogNewOraclizeQuery("Oraclize query was sent, standing by for the answer...");
            oraclize_query(
                "computation",
                [
                    "QmWFV2UrcUFMFk5R4iTZdusTRsvqohFwHjyXNH1Yu9v3Nm", // The ipfs multihash of archive.
                    "1" // Desired duration to run the stream (in minutes).
                ] 
            );
        }
    }
}
