/**
 * @notice  Provable Random Datasource Example
 *
 *          This contract uses the random-datasource to securely generate
 *          off-chain random bytes.
 *
 *          The random datasource is currently only available on the
 *          ethereum main-net & public test-nets (Ropsten, Rinkeby & Kovan).
 *
 */
pragma solidity >= 0.5.0 < 0.6.0;

import "./provableAPI.sol";

contract RandomExample is usingProvable {

    uint256 constant MAX_INT_FROM_BYTE = 256;
    uint256 constant NUM_RANDOM_BYTES_REQUESTED = 7;

    event LogNewProvableQuery(string description);
    event generatedRandomNumber(uint256 randomNumber);

    constructor()
        public
    {
        provable_setProof(proofType_Ledger);
        update();
    }

    function __callback(
        bytes32 _queryId,
        string memory _result,
        bytes memory _proof
    )
        public
    {
        require(msg.sender == provable_cbAddress());
        if (provable_randomDS_proofVerify__returnCode(_queryId, _result, _proof) != 0) {
            /**
             * @notice  The proof verification has failed! Handle this case
             *          however you see fit.
             */
        } else {
            /**
             *
             * @notice  The proof verifiction has passed!
             *
             *          Let's convert the random bytes received from the query
             *          to a `uint256`.
             *
             *          To do so, We define the variable `ceiling`, where
             *          `ceiling - 1` is the highest `uint256` we want to get.
             *          The variable `ceiling` should never be greater than:
             *          `(MAX_INT_FROM_BYTE ^ NUM_RANDOM_BYTES_REQUESTED) - 1`.
             *
             *          By hashing the random bytes and casting them to a
             *          `uint256` we can then modulo that number by our ceiling
             *          in order to get a random number within the desired
             *          range of [0, ceiling - 1].
             *
             */
            uint256 ceiling = (MAX_INT_FROM_BYTE ** NUM_RANDOM_BYTES_REQUESTED) - 1;
            uint256 randomNumber = uint256(keccak256(abi.encodePacked(_result))) % ceiling;
            emit generatedRandomNumber(randomNumber);
        }
    }

    function update()
        payable
        public
    {
        uint256 QUERY_EXECUTION_DELAY = 0; // NOTE: The datasource currently does not support delays > 0!
        uint256 GAS_FOR_CALLBACK = 200000;
        provable_newRandomDSQuery(
            QUERY_EXECUTION_DELAY,
            NUM_RANDOM_BYTES_REQUESTED,
            GAS_FOR_CALLBACK
        );
        emit LogNewProvableQuery("Provable query was sent, standing by for the answer...");
    }
}
