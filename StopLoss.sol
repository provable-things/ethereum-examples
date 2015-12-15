import "dev.oraclize.it/api.sol";

contract EtherStopLoss is usingOraclize {
  bytes32 krakenid;
  bytes32 shapeshiftid;
  
  function EtherStopLoss(){
    oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS)
  }

  function(){
    krakenTicker();
  }
    
  function krakenTicker() {
    krakenid = oraclize_query(60, "URL", "json(https://api.kraken.com/0/public/Ticker?pair=ETHXBT).result.XETHXXBT.c.0");
  }

  function __callback(bytes32 myid, string result, bytes proof) {
    if (msg.sender != oraclize_cbAddress()) throw;
    if ((myid == krakenid)&&(parseInt(result, 6) < 2000)){
      shapeshiftid = oraclize_query('URL', 'json(https://shapeshift.io/sendamount).success.deposit', '{"pair": "eth_btc", "amount": "0.2", "withdrawal": "1AAcCo21EUc1jbocjssSQDzLna9Vem2UN5"}');
    } else if (myid == shapeshiftid) {
      parseAddr(result).send(this.balance);
    } else {
      krakenTicker();
    }
  }
}    




  
