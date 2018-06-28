/*
    Diesel Price Peg

    This contract keeps in storage a reference
    to the Diesel Price in USD
*/
pragma solidity ^0.4.0;

import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";


contract DieselPrice is usingOraclize {

    uint public dieselPriceUSD;

    event NewOraclizeQuery(string description);
    event NewDieselPrice(string price);

    function DieselPrice() public {
        update(); // first check at contract creation
    }

    function __callback(bytes32 myid, string result) public {
        if (msg.sender != oraclize_cbAddress()) revert();
        NewDieselPrice(result);
        dieselPriceUSD = parseInt(result, 2); // let's save it as $ cents
        // do something with the USD Diesel price
    }

    function update() public payable {
        NewOraclizeQuery("Oraclize query was sent, standing by for the answer..");
        oraclize_query("URL", "xml(https://www.fueleconomy.gov/ws/rest/fuelprices).fuelPrices.diesel");
    }
}