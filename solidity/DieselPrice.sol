pragma solidity >= 0.5.0 < 0.6.0;

import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

contract DieselPrice is usingOraclize {

    uint public dieselPriceUSD;

    event LogNewDieselPrice(string price);
    event LogNewOraclizeQuery(string description);

    constructor()
        public
    {
        update(); // First check at contract creation...
    }

    function __callback(
        bytes32 _myid,
        string memory _result
    )
        public
    {
        require(msg.sender == oraclize_cbAddress());
        emit LogNewDieselPrice(_result);
        dieselPriceUSD = parseInt(_result, 2); // Let's save it as cents...
        // Now do something with the USD Diesel price...
    }

    function update()
        public
        payable
    {
        emit LogNewOraclizeQuery("Oraclize query was sent, standing by for the answer...");
        oraclize_query("URL", "xml(https://www.fueleconomy.gov/ws/rest/fuelprices).fuelPrices.diesel");
    }
}
