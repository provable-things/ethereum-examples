pragma solidity >= 0.5.0 < 0.6.0;

import "./oraclizeAPI.sol";

contract EncryptedQuery is usingOraclize {

    string public requestStatus;

    event LogNewProvableQuery(string description);
    event LogNewRequestStatus(string status);

    constructor()
        public
    {
        update(); // Update price on contract creation...
    }

    function __callback(
        bytes32 _myid,
        string memory _result,
        bytes memory _proof
    )
        public
    {
        require(msg.sender == oraclize_cbAddress());
        update(); // Recursively update the status stored in the contract...
        requestStatus = _result;
        emit LogNewRequestStatus(requestStatus);
    }

    function update()
        public
        payable
    {
        if (oraclize_getPrice("URL") > address(this).balance) {
            emit LogNewProvableQuery("Provable query was NOT sent, please add some ETH to cover for the query fee!");
        } else {
            emit LogNewProvableQuery("Provable query was sent, standing by for the answer...");
            //oraclize_query("URL","json(https://api.postcodes.io/postcodes).status",'{"postcodes" : ["OX49 5NU", "M32 0JG", "NE30 1DP"]}');
            oraclize_query(
                "URL",
                "BMqMhIFTTzsDbUSfPT233dVWB6wp0ksci7R/c6Jezcy3nEsnX7EQTaqRbej3shF7NlOwGRJAs1IBtYS32f6HrexffY+z1XMCHp+W6vFaIpDSVP0sVxiokuO0fr+ePxHOkvUh9x49BSmageBbHM1RB6QY/xhhvwJtssZOspEHvic=",
                "BDfT0gaCqtru/YRL/qEDEPTopcKe04wXtkRlDw0PNa8hazsDgKXv1G0pBVaHK5um6eTzAggrLKlXVLSUqI6rVzd9oaDST4Zo1NtLf2iMwWI0yx7sWwuhFY0Ot+OltgHLf8SclyRuHZHiOq+Ubx1pBtFGImYH4yMon1PgR+V9iWqN2gzv");
        }
    }
}
