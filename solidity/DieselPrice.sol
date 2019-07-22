pragma solidity >= 0.5.0 < 0.6.0;

import "github.com/provable/ethereum-api/provableAPI.sol";

contract DieselPrice is usingProvable {

    uint public dieselPriceUSD;

    event LogNewDieselPrice(string price);
    event LogNewProvableQuery(string description);

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
        require(msg.sender == provable_cbAddress());
        emit LogNewDieselPrice(_result);
        dieselPriceUSD = parseInt(_result, 2); // Let's save it as cents...
        // Now do something with the USD Diesel price...
    }

    function update()
        public
        payable
    {
        emit LogNewProvableQuery("Provable query was sent, standing by for the answer...");
        provable_query("URL", "xml(https://www.fueleconomy.gov/ws/rest/fuelprices).fuelPrices.diesel");
    }
}
