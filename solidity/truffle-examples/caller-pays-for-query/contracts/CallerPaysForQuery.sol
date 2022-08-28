pragma solidity >= 0.5.0 < 0.6.0;

import "./provableAPI.sol";

contract CallerPaysForQuery is usingProvable {

    string datasource = "URL";
    uint256 public queryPrice;
    string public ethPriceInUSD;

    event LogNewEthPrice(string _price);
    /**
     * @notice  Setting a custom gas price that's higher than the 20gwei default
     *          ensures `provable_getQueryPrice` returns the actual query price,
     *          rather than the _first_ query price would be free and ∴ zero
     *          when using default settings.
     */
    constructor()
        public
    {
        provable_setCustomGasPrice(21 * 10 ** 9);
        queryPrice = provable_getPrice(datasource);
    }

    function __callback(
        bytes32 _myid,
        string memory _result,
        bytes memory _proof
    )
        public
    {
        require(msg.sender == provable_cbAddress());
        ethPriceInUSD = _result;
        emit LogNewEthPrice(_result);
    }

    function getEthPriceInUSDViaProvable()
        public
        payable
    {
        require(
            queryPrice > 0 &&
            msg.value >= queryPrice
        );
        provable_query(
            datasource,
            "json(https://api.kraken.com/0/public/Ticker?pair=ETHUSD).result.XETHZUSD.c.0"
        );
        if (msg.value > queryPrice) {
            msg.sender.transfer(msg.value - queryPrice);
        }
    }
}
