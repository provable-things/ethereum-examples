/*
   Automated escrow handling ETH/BTC trades

   1- ETH funds are locked here by calling the "escrow" method
   2- every 10 minutes the smart contract checks for the BTC deposit:
      * if the deposit is there and has enough BTC, the ETH are unlocked and sent to the counterparty
      * if the deposit is not there..
        * .. and the time has expired, the ETH funds are sent back to the origin owner
        * .. and the time has not expired yet, another check is scheduled after 10 minutes

   NOTE: this only handles one escrow at a time, which must finish before a new request is submitted
*/

import "oraclizeAPI.sol";
import "iudexAPI.sol";

contract EthBtcEscrow is usingOraclize, usingIudex {
    uint mBTC;
    address ethAddr;
    address ethReturnAddr;
    string reqURL;
    uint timestampLimit;

    address constant IudexLookupAddr = 0x0;

    function EthBtcEscrow(){   
        oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
    }

    function getMinConfirmationsByAddr(address _ethAddr) internal returns (uint) {
        uint score = getIudexScoreAll(IudexLookupAddr, _ethAddr);
        return 10 - ((score - 1)/100000);
    }

    function escrow(uint _mBTC, string _btcAddr, address _ethAddr, uint _timestampLimit) {
        mBTC = _mBTC;
        ethAddr = _ethAddr;
        ethReturnAddr = msg.sender;
        string memory head = "json(https://chain.so/api/v2/get_address_balance/BTC/";
        bytes memory _head = bytes(url);
        bytes memory __btcAddr = bytes(_btcAddr);
        uint confs = getMinConfirmationsByAddr(_ethAddr);
        string memory tail = ").data.confirmed_balance";
        bytes memory _tail = bytes(tail);
        string memory url = new string(_head.length + __btcAddr.length + 2 + _tail.length);
        bytes memory _url = bytes(url);
        uint i = 0;
        for (uint j = 0; j < _head.length; j++)
            _url[i++] = _head[j];
        for (j = 0; j < __btcAddr.length; j++)
            _url[i++] = __btcAddr[j];
        _url[i++] = byte("/");
        _url[i++] = byte(48 + confs);
        for (j = 0; j < _tail.length; j++)
            _url[i++] = _tail[j];
        reqURL = url;
        timestampLimit = _timestampLimit;
        oraclize_query("URL", url);
    }

    function __callback(bytes32 myid, string result, bytes proof) {
        if (msg.sender != oraclize_cbAddress()) throw;
        if (parseInt(result, 3) >= mBTC) ethAddr.send(this.balance);
        else if (now > timestampLimit) ethReturnAddr.send(this.balance);
        else oraclize_query(60*10, "URL", reqURL);
    }

}
