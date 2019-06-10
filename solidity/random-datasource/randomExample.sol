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

import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

contract RandomExample is usingOraclize {

    event LogNewOraclizeQuery(string description);
    event generatedRandomNumber(uint256 randomNumber);

    constructor()
        public
    {
        oraclize_setProof(proofType_Ledger);
        update();
    }

    function __callback(
        bytes32 _queryId,
        string memory _result,
        bytes memory _proof
    )
        public
    {
        require(msg.sender == oraclize_cbAddress());

        if (
            oraclize_randomDS_proofVerify__returnCode(
                _queryId,
                _result,
                _proof
            ) != 0
        ) {
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
             *          to a `uint256`. To do so, We define the variable
             *          maxRange, where maxRange - 1 is the highest uint256 we
             *          want to get. The variable maxRange should never be
             *          greater than: 2 ^ (8 * NUM_RANDOM_BYTES_REQUESTED).
             *
             *          Then we perform the modulo `maxRange` of the keccak256
             *          hash of the random bytes cast to `uint256` to obtain a
             *          random number in the interval [0, maxRange - 1].
             *
             */
            uint256 maxRange = 2 ** (8 * 7);
            uint256 randomNumber = uint256(keccak256(abi.encodePacked(_result))) % maxRange;
            emit generatedRandomNumber(randomNumber);
        }
    }

    function update()
        payable
        public
    {
        uint256 QUERY_EXECUTION_DELAY = 0;
        uint256 GAS_FOR_CALLBACK = 200000;
        uint256 NUM_RANDOM_BYTES_REQUESTED = 7;
        oraclize_newRandomDSQuery(
            QUERY_EXECUTION_DELAY,
            NUM_RANDOM_BYTES_REQUESTED,
            GAS_FOR_CALLBACK
        );
        emit LogNewOraclizeQuery("Oraclize query was sent, standing by for the answer...");
    }
}
