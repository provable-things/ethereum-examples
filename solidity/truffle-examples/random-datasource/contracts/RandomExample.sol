/**
 * Oraclize Random Datasource Example
 *
 * This contract uses the random-datasource to securely generate off-chain
 * random bytes.
 *
 * @notice The random datasource is currently only available on the
 * ethereum main-net & public test-nets (Ropsten, Rinkeby & Kovan).
 *
 */
pragma solidity >= 0.5.0 < 0.6.0;

import "./oraclizeAPI.sol";

contract RandomExample is usingOraclize {

    event newRandomNumber_bytes(bytes);
    event newRandomNumber_uint(uint);

    constructor()
        public
    {
        oraclize_setProof(proofType_Ledger); // sets the Ledger authenticity proof in the constructor
        update(); // let's ask for random bytes immediately when the contract is created!
    }

    // the callback function is called by Oraclize when the result is ready
    // the oraclize_randomDS_proofVerify modifier prevents an invalid proof to execute this function code:
    // the proof validity is fully verified on-chain
    function __callback(
        bytes32 _queryId,
        string memory _result,
        bytes memory _proof
    )
        public
    {
        require(msg.sender == oraclize_cbAddress());

        if (oraclize_randomDS_proofVerify__returnCode(_queryId, _result, _proof) != 0) {
            // the proof verification has failed, do we need to take any action here? (depends on the use case)
        } else {
            // the proof verification has passed
            // now that we know that the random number was safely generated, let's use it...

            emit newRandomNumber_bytes(bytes(_result)); // emit the resulting random number (in bytes)

            /**
             * for simplicity of use, let's also convert the random bytes to uint:
             * first, we define the variable maxRange, where maxRange - 1 is the highest uint we
             * want to get. The variable maxRange should never be greater than 2^(8*N), where N is
             * the number of random bytes we had asked the datasource to return.
             * finally, we perform the modulo maxRange of the sha3 hash of the random bytes casted
             * to uint to obtain a random number ∈ [0, maxRange - 1].
             */
            uint maxRange = 2 ** (8 * 7); // N = 7
            uint randomNumber = uint(keccak256(abi.encodePacked(_result))) % maxRange; // random number ∈ [0, 2^56 - 1]

            emit newRandomNumber_uint(randomNumber); // emit the resulting random number (in uint)
        }
    }

    function update()
        payable
        public
    {
        uint N = 7; // number of random bytes we want the datasource to return
        uint delay = 0; // number of seconds to wait before the execution takes place
        uint callbackGas = 200000; // amount of gas we want Oraclize to set for the callback function
        bytes32 queryId = oraclize_newRandomDSQuery(delay, N, callbackGas); // this function internally generates the correct oraclize_query and returns its queryId
    }
}
