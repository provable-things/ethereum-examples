/*
    Diesel Price Peg

    This contract keeps in storage a reference
    to the Diesel Price in USD
*/
pragma solidity ^0.4.25;
import "https://raw.githubusercontent.com/oraclize/ethereum-api/master/oraclizeAPI_0.4.25.sol";

contract DieselPrice is usingOraclize {

    uint256 public dieselPriceUSD;

    event NewOraclizeQuery(string _description);
    event NewDieselPrice(string _price);

    constructor() public payable {
        update(); // first check at contract creation
    }

    function __callback(bytes32 _myid, string _result) public {
        if (msg.sender != oraclize_cbAddress()) revert();
        emit NewDieselPrice(_result);
        dieselPriceUSD = parseInt(_result, 2); // Let's save it as $ cents (2 decimal places)
        // Do something with the USD Diesel price
    }

    function update() public payable {
        emit NewOraclizeQuery("Oraclize query was sent, standing by for the answer...");
        oraclize_query("URL", "xml(https://www.fueleconomy.gov/ws/rest/fuelprices).fuelPrices.diesel");
    }
    
}
