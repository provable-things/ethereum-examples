/*
   Kraken-based ETH/XBT price ticker

   This contract keeps in storage an updated ETH/XBT price,
   which is updated every ~60 seconds.
*/
pragma solidity ^0.4.0;

import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";


contract KrakenPriceTicker is usingOraclize {

    string public priceETHXBT;

    event NewOraclizeQuery(string description);
    event NewKrakenPriceTicker(string price);

    function KrakenPriceTicker() public {
        oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
        update();
    }

    function __callback(bytes32 myid, string result, bytes proof) public {
        if (msg.sender != oraclize_cbAddress()) revert();
        priceETHXBT = result;
        NewKrakenPriceTicker(priceETHXBT);
        update();
    }

    function update() public payable {
        if (oraclize_getPrice("URL") > this.balance) {
            NewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            NewOraclizeQuery("Oraclize query was sent, standing by for the answer..");
            oraclize_query(60, "URL", "json(https://api.kraken.com/0/public/Ticker?pair=ETHXBT).result.XETHXXBT.c.0");
        }
    }
}
