pragma solidity >= 0.5.0 < 0.6.0;

import "./oraclizeAPI.sol";

contract CallerPaysForQuery is usingOraclize {

    string datasource = "URL";
    uint256 public queryPrice;
    string public ethPriceInUSD;

    event LogNewEthPrice(string _price);
    /**
     * @notice  Setting a custom gas price that's higher than the 20gwei default
     *          ensures `oraclize_getQueryPrice` returns the actual query price,
     *          rather than the _first_ query price would be free and ∴ zero
     *          when using default settings.
     */
    constructor()
        public
    {
        oraclize_setCustomGasPrice(21 * 10 ** 9);
        queryPrice = oraclize_getPrice(datasource);
    }

    function __callback(
        bytes32 _myid,
        string memory _result,
        bytes memory _proof
    )
        public
    {
        require(msg.sender == oraclize_cbAddress());
        ethPriceInUSD = _result;
        emit LogNewEthPrice(ethPriceInUSD);
    }

    function getEthPriceInUSDViaProvable()
        public
        payable
    {
        require(
            queryPrice > 0 &&
            msg.value >= queryPrice
        );
        oraclize_query(
            datasource,
            "json(https://api.kraken.com/0/public/Ticker?pair=ETHUSD).result.XETHZUSD.c.0"
        );
        if (msg.value > queryPrice) {
            msg.sender.transfer(msg.value - queryPrice);
        }
    }
}
