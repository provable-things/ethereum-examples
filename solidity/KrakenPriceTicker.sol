/*
   Kraken-based ETH/XBT price ticker

   This contract keeps in storage an updated ETH/XBT price,
   which is updated every ~60 seconds.
*/
pragma solidity ^0.4.25;
import "https://raw.githubusercontent.com/oraclize/ethereum-api/master/oraclizeAPI_0.4.25.sol";

contract KrakenPriceTicker is usingOraclize {

    string public priceETHXBT;

    event NewOraclizeQuery(string _description);
    event NewKrakenPriceTicker(string _price);

    constructor() public payable {
        oraclize_setProof(proofType_Android | proofStorage_IPFS);
        update();
    }

    function __callback(bytes32 _myid, string _result, bytes _proof) public {
        if (msg.sender != oraclize_cbAddress()) revert();
        priceETHXBT = _result;
        emit NewKrakenPriceTicker(priceETHXBT);
        update();
    }

    function update() public payable {
        if (oraclize_getPrice("URL") > this.balance) {
            emit NewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            emit NewOraclizeQuery("Oraclize query was sent, standing by for the answer...");
            oraclize_query(60, "URL", "json(https://api.kraken.com/0/public/Ticker?pair=ETHXBT).result.XETHXXBT.c.0");
        }
    }
}


