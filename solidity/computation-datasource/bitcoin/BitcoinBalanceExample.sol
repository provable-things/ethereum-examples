pragma solidity >= 0.5.0 < 0.6.0;

import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

contract BitcoinBalanceExample is usingOraclize {

    uint256 public balance;

    event LogBitcoinAddressBalance(uint _balance);

    constructor()
        public
    {
        getBalance("3D2oetdNuZUqQHPJmcMDDHYoqkyNVsFk9r");
    }

    function __callback(
        bytes32 _myid,
        string memory _result
    )
        public
    {
        require(msg.sender == oraclize_cbAddress());
        balance = parseInt(_result, 8);
        emit LogBitcoinAddressBalance(balance);
    }

    function getBalance(
        string memory _bitcoinAddress
    )
        public
        payable
    {
        oraclize_query("computation", ["QmNecqR52vCsxshJx6acki6Nhg8zYLiRco4fwt22Yq2Qiz", _bitcoinAddress]);
    }
}
