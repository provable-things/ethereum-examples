pragma solidity >= 0.5.0 < 0.6.0;

import "./oraclizeAPI.sol";

contract StreamrTweetsCounter is usingOraclize {

    uint public numberOfTweets;

    event LogResult(string result);
    event LogNewOraclizeQuery(string description);

    constructor()
        public
    {
        update(); // First check at contract creation...
    }

    function __callback(
        bytes32 _myid,
        string memory _result
    )
        public
    {
        require(msg.sender == oraclize_cbAddress());
        numberOfTweets = parseInt(_result);
        emit LogResult(_result);
    }

    function update()
        public
        payable
    {
        if (oraclize_getPrice("computation") > address(this).balance) {
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
