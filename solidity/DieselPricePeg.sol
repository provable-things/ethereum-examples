import "dev.oraclize.it/api.sol";

contract DieselPricePeg is usingOraclize {
    
    uint public DieselPriceUSD;
    

    function DieselPricePeg() {
        oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
        update(0); // first check at contract creation
    }

    function __callback(bytes32 myid, string result, bytes proof) {
        if (msg.sender != oraclize_cbAddress()) throw;
        DieselPriceUSD = parseInt(result, 2); // let's save it as $ cents
        // do something with the USD Diesel price
        update(60*10); // schedule another check in 10 minutes
    }
    
    function update(uint delay) {
        oraclize_query(delay, "URL", "xml(https://www.fueleconomy.gov/ws/rest/fuelprices).fuelPrices.diesel");
    }
    
}

