/*
   Youtube video views-count based escrow
*/


import "dev.oraclize.it/api.sol";

contract YoutubeViews is usingOraclize {
    
    uint public viewsCount;
    string public videoID;
    address public owner;
    uint public expiryDate;
    uint public threshold;
    
    
    mapping (address => uint) public sponsors;
    address[] public sponsorsList;

    function YoutubeViews() {
        owner = msg.sender;
        //oraclize_setNetwork(networkID_testnet);
    }
    
    function setVideoID(string _videoID, uint _threshold) {
        if ((msg.sender != owner)||(bytes(videoID).length != 0)||(bytes(_videoID).length == 0)) throw;
        videoID = _videoID;
        uint _expiryDate = now+1*week;
        expiryDate = _expiryDate;
        threshold = _threshold;
        sendQuery(_expiryDate);
    }

    function() {
        sponsorDeposit();
    }
    
    function sponsorDeposit() public {
        if ((msg.value == 0)||(bytes(videoID).length == 0)) throw;
        if (sponsors[msg.sender] == 0) sponsorsList[sponsorsList.length++] = msg.sender;
        sponsors[msg.sender] += msg.value;
        if ((now >= expiryDate)&&(viewsCount > 0)) processWithdrawals();
    }

    function __callback(bytes32 myid, string result) {
        if (msg.sender != oraclize_cbAddress()) throw;
        viewsCount = parseInt(result);
        processWithdrawals();
    }
    
    function processWithdrawals() internal {
        if (viewsCount < threshold) {
            address _sponsor;
            for (uint i=0; i<sponsorsList.length; i++){
                _sponsor = sponsorsList[i];
                _sponsor.send(sponsors[_sponsor]/4);
            }
        }
        owner.send(this.balance);
    }
    
    function sendQuery(uint delay) internal {
        string memory videoURL = strConcat('html(https://www.youtube.com/watch?v=', videoID, ').xpath(//*[contains(@class, "watch-view-count")]/text())');
        oraclize_query(delay, 'URL', videoURL);
    }
    
    function forceCheck() public {
        if ((msg.sender != owner)||(now < expiryDate+60*60)) throw;
        sendQuery(expiryDate);
    }
    
} 
                                                                             
