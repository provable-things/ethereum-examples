pragma solidity  >= 0.5.0 < 0.6.0;

import "./oraclizeAPI.sol";

contract DelegatedMath is usingOraclize {

    event LogOperationResult(uint result);

    constructor()
        public
    {
        oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
        delegateOperation("32", "125");
    }

    function __callback(
        bytes32 _myid,
        string memory _result,
        bytes memory _proof
    )
        public
    {
        require(msg.sender == oraclize_cbAddress());
        emit LogOperationResult(parseInt(_result));
    }

    function delegateOperation(
        string memory _firstOperand,
        string memory _secondOperand
    )
        public
        payable
    {
        oraclize_query("computation", ["Qmc8jmuT47cPWadF8ZhErGXj7J4VEp5H29knukCGirsN19", _firstOperand, _secondOperand]);
    }
}
