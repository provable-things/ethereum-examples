/*
   Kraken-based ETH/XBT price ticker

   This contract keeps in storage an updated ETH/XBT price,
   which is updated every ~60 seconds.
*/

pragma solidity ^0.4.0;

// import library manually here, library github linking not working with oraclize browser-solidity
import "oraclizeLib.sol";

contract KrakenPriceTicker {

    string public ETHXBT;

    event newOraclizeQuery(string description);
    event newKrakenPriceTicker(string price);


    function KrakenPriceTicker() {
        oraclizeLib.oraclize_setProof(oraclizeLib.proofType_TLSNotary() | oraclizeLib.proofStorage_IPFS());
        update();
    }

    function __callback(bytes32 myid, string result, bytes proof) {
        if (msg.sender != oraclizeLib.oraclize_cbAddress()) throw;
        ETHXBT = result;
        newKrakenPriceTicker(ETHXBT);
        update();
    }

    function update() payable {
        if (oraclizeLib.oraclize_getPrice("URL") > this.balance) {
            newOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            newOraclizeQuery("Oraclize query was sent, standing by for the answer..");
            oraclizeLib.oraclize_query(60, "URL", "json(https://api.kraken.com/0/public/Ticker?pair=ETHXBT).result.XETHXXBT.c.0");
        }
    }

}
