pragma solidity >= 0.5.0 < 0.6.0;

import "github.com/provable-things/ethereum-api/provableAPI.sol";

contract YoutubeViews is usingProvable {

    string public viewsCount;

    event LogYoutubeViewCount(string views);
    event LogNewProvableQuery(string description);

    constructor()
        public
    {
        update(); // Update views on contract creation...
    }

    function __callback(
        bytes32 _myid,
        string memory _result
    )
        public
    {
        require(msg.sender == provable_cbAddress());
        viewsCount = _result;
        emit LogYoutubeViewCount(viewsCount);
        // Do something with viewsCount, like tipping the author if viewsCount > X?
    }

    function update()
        public
        payable
    {
        emit LogNewProvableQuery("Provable query was sent, standing by for the answer...");
        provable_query("URL", 'html(https://www.youtube.com/watch?v=9bZkp7q19f0).xpath(//*[contains(@class, "watch-view-count")]/text())');
    }
}
