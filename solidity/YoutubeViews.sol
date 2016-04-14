/*
   Youtube video views

   This contract keeps in storage an always-in-sync views
   counter for a certain Youtube video.
*/


import "dev.oraclize.it/api.sol";

contract YoutubeViews is usingOraclize {
    
    uint public viewsCount;

    function YoutubeViews() {
        update(0);
    }
    

    function __callback(bytes32 myid, string result) {
        if (msg.sender != oraclize_cbAddress()) throw;
        viewsCount = parseInt(result, 0);
        // do something with viewsCount
        // (like tipping the author once viewsCount > X?)
        update(60*10); // update viewsCount every 10 minutes
    }
    
    function update(uint delay) {
        oraclize_query(delay, 'URL', 'html(https://www.youtube.com/watch?v=9bZkp7q19f0).xpath(//*[contains(@class, "watch-view-count")]/text())');
    }
    
} 
                                           
