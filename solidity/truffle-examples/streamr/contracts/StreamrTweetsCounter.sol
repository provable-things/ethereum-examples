pragma solidity >= 0.5.0 < 0.6.0;

import "./provableAPI.sol";

contract StreamrTweetsCounter is usingProvable {

    uint public numberOfTweets;

    event LogResult(string result);
    event LogNewProvableQuery(string description);

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
        require(msg.sender == provable_cbAddress());
        numberOfTweets = parseInt(_result);
        emit LogResult(_result);
    }

    function update()
        public
        payable
    {
        if (provable_getPrice("computation") > address(this).balance) {
            emit LogNewProvableQuery("Provable query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            emit LogNewProvableQuery("Provable query was sent, standing by for the answer...");
            provable_query(
                "computation",
                [
                    "QmWFV2UrcUFMFk5R4iTZdusTRsvqohFwHjyXNH1Yu9v3Nm", // The ipfs multihash of archive.
                    "1" // Desired duration to run the stream (in minutes).
                ]
            );
        }
    }
}
