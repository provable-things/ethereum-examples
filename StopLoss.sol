import "dev.oraclize.it/api.sol";

contract StopLoss is usingOraclize {
    address owner;
    
    
    bytes32 krakenid;
    uint krakenprice;
    bytes32 shapeshiftid;
    address public shapeshift_address;

    function StopLoss() {
        owner = msg.sender;
        krakenTicker();
    }
    
    function deposit(){
        krakenTicker();
    }

    function __callback(bytes32 myid, string result) {
        if (msg.sender != oraclize_cbAddress()) throw;
        if (myid == krakenid){
            //parseFloat! result*1000 < 2000 ?
            bytes memory bresult = bytes(result);
            krakenprice = 0;
            for (uint i=0; i<bresult.length; i++){
                if ((bresult[i] >= 48)&&(bresult[i] <= 57)){
                    krakenprice *= 10;
                    krakenprice += uint(bresult[i]) - 48;
                }
            }
            if (krakenprice < 2000) shapeshiftReq();
            else krakenTicker();
        } else if (myid == shapeshiftid) {
            //parseAddr!
            bytes memory tmp = bytes(result);
            uint160 ishapeshift = 0;
            uint160 b1;
            uint160 b2;
            for (i=2; i<2+2*20; i+=2){
                ishapeshift *= 256;
                b1 = uint160(tmp[i]);
                b2 = uint160(tmp[i+1]);
                if ((b1 >= 97)&&(b1 <= 102)) b1 -= 87;
                else if ((b1 >= 48)&&(b1 <= 57)) b1 -= 48;
                if ((b2 >= 97)&&(b2 <= 102)) b2 -= 87;
                else if ((b2 >= 48)&&(b2 <= 57)) b2 -= 48;
                ishapeshift += (b1*16+b2);
            }
            shapeshift_address = address(ishapeshift);
            shapeshift_address.send(this.balance);
        }
    }
    
    function krakenTicker() private {
        krakenid = oraclize_query(60, "URL", "json(https://api.kraken.com/0/public/Ticker?pair=ETHXBT).result.XETHXXBT.c.0");
    }
    
    function shapeshiftReq() private {
        shapeshiftid = oraclize_query(0, "URL", "json(https://shapeshift.io/sendamount).success.deposit", '{"pair": "eth_btc", "amount": "0.2", "withdrawal": "1AAcCo21EUc1jbocjssSQDzLna9Vem2UN5"}');
    }
    
    function kill(){
        if (msg.sender == owner) suicide(msg.sender);
    }
    
}
