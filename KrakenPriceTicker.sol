import "dev.oraclize.it/api.sol";

contract PriceTicker is usingOraclize {
    
    address owner;
    string public ETHXBT;
    

    function PriceTicker() {
        owner = msg.sender;
        update();
    }

    function __callback(bytes32 myid, string result) {
        if (msg.sender != oraclize_cbAddress()) throw;
        ETHXBT = result;
    }
    
    function update() {
        oraclize_query("URL", "json(https://api.kraken.com/0/public/Ticker?pair=ETHXBT).result.XETHXXBT.c.0");
    }
    
    function kill(){
        if (msg.sender == owner) suicide(msg.sender);
    }
    
} 
