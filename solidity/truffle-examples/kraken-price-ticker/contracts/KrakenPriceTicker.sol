pragma solidity >= 0.5.0 < 0.6.0;

import "./oraclizeAPI.sol";

contract KrakenPriceTicker is usingOraclize {

    string public priceETHXBT;

    event LogNewOraclizeQuery(string description);
    event LogNewKrakenPriceTicker(string price);

    constructor() public {
        oraclize_setProof(proofType_Android | proofStorage_IPFS);
        update(); // Update price on contract creation...
    }

    function __callback(bytes32 myid, string memory result, bytes memory proof) public {
        require(msg.sender == oraclize_cbAddress());
        update(); // Recursively update the price stored in the contract...
        priceETHXBT = result;
        emit LogNewKrakenPriceTicker(priceETHXBT);
    }

    function update() public payable {
        if (oraclize_getPrice("URL") > address(this).balance) {
            emit LogNewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee!");
        } else {
            emit LogNewOraclizeQuery("Oraclize query was sent, standing by for the answer...");
            oraclize_query(60, "URL", "json(https://api.kraken.com/0/public/Ticker?pair=ETHXBT).result.XETHXXBT.c.0");
        }
    }
}
