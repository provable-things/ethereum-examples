/*
    Youtube Video Views

    This contract keeps in storage a views counter
    for a given Youtube video.
*/

pragma solidity ^0.4.25;
import "https://raw.githubusercontent.com/oraclize/ethereum-api/master/oraclizeAPI_0.4.25.sol";

contract YoutubeViews is usingOraclize {

    string public viewsCount;

    event NewOraclizeQuery(string _description);
    event NewYoutubeViewsCount(string _views);

    constructor() public payable {
        update();
    }

    function __callback(bytes32 _myid, string _result) public {
        if (msg.sender != oraclize_cbAddress()) revert();
        viewsCount = _result;
        emit NewYoutubeViewsCount(viewsCount);
        // Do something with viewsCount. Like tipping the author if viewsCount > x?
    }

    function update() public payable {
        emit NewOraclizeQuery("Oraclize query was sent, standing by for the answer...");
        oraclize_query("URL", 'html(https://www.youtube.com/watch?v=9bZkp7q19f0).xpath(//*[contains(@class, "watch-view-count")]/text())');
    }
}
