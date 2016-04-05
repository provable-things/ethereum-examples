/*
   Kraken-based ETH/XBT price ticker

   This contract keeps in storage an updated ETH/XBT price,
   which is updated every ~60 seconds.
*/

import "dev.oraclize.it/api.sol";

contract KrakenPriceTicker is usingOraclize {
    
    address owner;
    string public ETHXBT;
    

    function KrakenPriceTicker() {
        owner = msg.sender;
        oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
        update();
    }

    function __callback(bytes32 myid, string result, bytes proof) {
        if (msg.sender != oraclize_cbAddress()) throw;
        ETHXBT = result;
        update();
    }
    
    function update() {
        oraclize_query(60, "URL", "json(https://api.kraken.com/0/public/Ticker?pair=ETHXBT).result.XETHXXBT.c.0");
    }
    
    function kill(){
        if (msg.sender == owner) suicide(msg.sender);
    }
    
} 
