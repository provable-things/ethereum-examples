/**
 * @notice  Provable Random Datasource Example - Relaxed Commit Version
 *
 *          This contract uses the random-datasource to securely generate
 *          off-chain random bytes. The relaxed commit parameters result in a
 *          greater chance of a passing proof in exchange for lower security
 *          guarantees.
 *
 *          The random datasource is currently only available on the
 *          ethereum main-net & public test-nets (Ropsten, Rinkeby & Kovan).
 *
 */
pragma solidity >= 0.5 < 0.6;

import "github.com/oraclize/ethereum-api/oraclizeAPI_0.5.sol";

contract RandomRelaxedExample is usingOraclize {

    uint256 constant MAX_INT_FROM_BYTE = 256;
    uint256 constant NUM_RANDOM_BYTES_REQUESTED = 7;

    event LogNewOraclizeQuery(string _description);
    event generatedRandomNumber(uint256 _randomUint);

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
        public
        payable
    {
        uint256 QUERY_EXECUTION_DELAY = 0;
        uint256 GAS_FOR_CALLBACK = 200000;
        oraclize_newRandomDSQuery(
            QUERY_EXECUTION_DELAY,
            NUM_RANDOM_BYTES_REQUESTED,
            GAS_FOR_CALLBACK
        );
        emit LogNewOraclizeQuery(
            "Oraclize query was sent, standing by for the answer..."
        );
    }
    /**
     *
     * @notice  This overrides the Random Datasource function from `oraclizeAPI`
     *          with a more relaxed one that should fail due to re-orgs much
     *          less frequently.
     *
     */
    function oraclize_newRandomDSQuery(
        uint256 _delay,
        uint256 _nbytes,
        uint256 _customGasLimit
    )
        internal
        returns (bytes32 _queryId)
    {
        require((_nbytes > 0) && (_nbytes <= 32));
        _delay *= 10;
        bytes memory nbytes = new bytes(1);
        nbytes[0] = byte(uint8(_nbytes));
        bytes memory unonce = new bytes(32);
        bytes memory sessionKeyHash = new bytes(32);
        bytes32 sessionKeyHash_bytes32 = oraclize_randomDS_getSessionPubKeyHash();
        assembly {
            mstore(unonce, 0x20)
            /**
             *
             * @dev Here is the edit: It removes xoring of last blockhash with
             *      some current block variables, with that of a block committed
             *      for a modulo range. This will lower chance of false proof
             *      fails, by an expected factor of `NUM_RANDOM_BYTES_REQUESTED`.
             *
             *      The original function reads:
             *
             *      mstore(
             *          add(unonce, 0x20),
             *          xor(blockhash(sub(number, 1)),
             *          xor(coinbase, timestamp))
             *      )
             *
             */
            mstore(
                add(unonce, 0x20),
                blockhash(sub(sub(number, 1), mod(number, 6)))
            )
            mstore(sessionKeyHash, 0x20)
            mstore(add(sessionKeyHash, 0x20), sessionKeyHash_bytes32)
        }
        bytes memory delay = new bytes(32);
        assembly {
            mstore(add(delay, 0x20), _delay)
        }

        bytes memory delay_bytes8 = new bytes(8);
        copyBytes(delay, 24, 8, delay_bytes8, 0);

        bytes[4] memory args = [unonce, nbytes, sessionKeyHash, delay];
        bytes32 queryId = oraclize_query("random", args, _customGasLimit);

        bytes memory delay_bytes8_left = new bytes(8);

        assembly {
            let x := mload(add(delay_bytes8, 0x20))
            mstore8(
                add(delay_bytes8_left, 0x27),
                div(x, 0x100000000000000000000000000000000000000000000000000000000000000)
            )
            mstore8(
                add(delay_bytes8_left, 0x26),
                div(x, 0x1000000000000000000000000000000000000000000000000000000000000)
            )
            mstore8(
                add(delay_bytes8_left, 0x25),
                div(x, 0x10000000000000000000000000000000000000000000000000000000000)
            )
            mstore8(
                add(delay_bytes8_left, 0x24),
                div(x, 0x100000000000000000000000000000000000000000000000000000000)
            )
            mstore8(
                add(delay_bytes8_left, 0x23),
                div(x, 0x1000000000000000000000000000000000000000000000000000000)
            )
            mstore8(
                add(delay_bytes8_left, 0x22),
                div(x, 0x10000000000000000000000000000000000000000000000000000)
            )
            mstore8(
                add(delay_bytes8_left, 0x21),
                div(x, 0x100000000000000000000000000000000000000000000000000)
            )
            mstore8(
                add(delay_bytes8_left, 0x20),
                div(x, 0x1000000000000000000000000000000000000000000000000)
            )

        }

        oraclize_randomDS_setCommitment(
            queryId,
            keccak256(
                abi.encodePacked(
                    delay_bytes8_left,
                    args[1],
                    sha256(args[0]),
                    args[2]
                )
            )
        );
        return queryId;
    }
}
