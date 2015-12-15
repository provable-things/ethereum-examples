/*
   Simple "roll a Dice".

   After calling the "bet" method along with 1 wei,
   the contract asks Wolfram Alpha to roll a dice.
   You get back either 0 wei or 2.
*/

import "dev.oraclize.it/api.sol";

contract SimpleDice is usingOraclize {
    address owner;
    mapping (bytes32 => address) bets;

    function Lottery(){
        owner = msg.sender;
    }

    function __callback(bytes32 myid, string result) {
        if (msg.sender != oraclize_cbAddress()) throw;
        if (uint(bytes(result)[0]) - 48 > 3) bets[myid].send(2);
    }
    
    function bet(){
        if ((msg.value != 1)||(this.balance < 2)) throw;
        rollDice();
    }
    
    function rollDice() {
        bytes32 myid = oraclize_query(0, "WolframAlpha", "random number between 1 and 6");
        bets[myid] = msg.sender;
    }
    
    function kill(){
        if (msg.sender == owner) suicide(msg.sender);
    }
}
