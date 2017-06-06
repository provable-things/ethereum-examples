/*
   Computation N args query example
   Takes up to 16 string args and concatenates them
   off-chain with a python script

   Also makes use of InlineDynamicHelper library
   for converting inline fixed string array declarations
   to dynamic-sized arrays, which is what the Oraclize library expects
*/

// NOTE, the computations here may crash remix's JavascriptVM
// Ensure you are loading in an incognito window, and in a single session
// only deploying and then calling the update function

pragma solidity ^0.4.0;

// import both libraries manually
import "oraclizeLib.sol";
import "InlineDynamicHelper.sol";

contract OffchainConcat is usingInlineDynamic {

    string public CONCATENATED;
    address public OAR = oraclizeLib.getOAR();
    OraclizeI public localOrclInstance = oraclizeLib.getCON();
    uint constant public base = localOrclInstance.getPrice("URL");

    event newOraclizeQuery(string description);
    event emitConcatMsg(string msg);


    function OffchainConcat() {
        oraclizeLib.oraclize_setProof(oraclizeLib.proofType_NONE());
    }

    function __callback(bytes32 myid, string result) {
        if (msg.sender != oraclizeLib.oraclize_cbAddress()) throw;
        CONCATENATED = result;
        emitConcatMsg(result);
    }

    function update() payable {
        if (oraclizeLib.oraclize_getPrice("computation") > this.balance) {
            newOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            newOraclizeQuery("Oraclize query was sent, standing by for the answer..");

            oraclizeLib.oraclize_query("computation",
                ["QmQ4kKevJhmPfB3bNHh4xBVo4EE8fd3L7yoTVKPe6DCFus",
                "Last",
                "entry",
                "will",
                "be",
                "bytes:",
                oraclizeLib.b2s(hex'DEADBEEF1001') // bytes to string equivalent conversion
                ].toDynamic()
            );
        }
    }

}
