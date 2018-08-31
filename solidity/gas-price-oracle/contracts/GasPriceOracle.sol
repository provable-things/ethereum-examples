pragma solidity 0.4.24;

import "./imported/strings.sol";
import "./imported/usingOraclize.sol";

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    /**
     * @notice Multiplies two numbers, throws on overflow.
     *
     */
    function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
        // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (_a == 0) return 0;
        c = _a * _b;
        require(c / _a == _b, 'SafeMath multiplication threw!');
        return c;
    }
    /**
     * @notice Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
     *
     */
    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b <= _a, 'SafeMath subtraction threw!');
        return _a - _b;
    }
}
/**
 * @title   GasPriceOracle
 *
 * @notice  A contract for querying ethereum gas prices from the ETH  
 *          Gas Station. Recursive Oraclize calls will retrieve the  
 *          latest prices at 6 hourly intervals. In addition, any  
 *          interested party is able to call the `updateGasPrices`  
 *          function at any time to update the prices. 
 *
 * @dev     The contract exposes the public, view functions:  
 *          `getSafeLowPrice`, `getStandardPrice` & `getFastPrice`  
 *          each of which return their respective gas prices in Wei,
 *          and as type uint256. The `getGasPrices` function returns 
 *          a tuple with all three gas prices in Wei as uint256, ordered 
 *          from slowest to fastest, as well as the time the prices were 
 *          last updated. The `getLastUpdated` function returns the time 
 *          when the gas prices were last updated, as a UTC timestamp 
 *          of type uint256.
 *
 */
contract GasPriceOracle is usingOraclize {
    using strings for *;
    using SafeMath for *;

    uint    constant public interval = 6;
    uint    constant public gasLimit = 187000;
    uint    constant public gasLimitRec = 200000;
    uint    constant public conversionFactor = 100000000;
    string  constant public queryString = "json(https://ethgasstation.info/json/ethgasAPI.json).[safeLow,average,fast]";

    GasStationPrices public gasStationPrices;

    struct GasStationPrices { // 100 mwei prices inherited from ethgasstation
        uint64 safeLow;       // gas price * 100 mwei for a transaction time < 30 minutes
        uint64 standard;      // gas price * 100 mwei for a transaction time <  5 minutes
        uint64 fast;          // gas price * 100 mwei for a transaction time <  2 minutes
        uint64 timeUpdated;   // timestamp of when the current prices were last updated.
    }

    mapping(bytes32 => QueryIDs) public queryIDs;

    struct QueryIDs {
        bool isManual;
        bool isProcessed;
        bool isRevival;
        uint64 dueAt;
        uint128 gasPriceUsed;
    }

    bytes32 public nextRecursiveQuery;

    event LogInsufficientBalance();
    event LogGasPricesUpdated(uint64 safeLowPrice, uint64 standardPrice, uint64 fastPrice, bytes32 queryID, bytes IPFSMultihash);
    /**
     * @notice  Constructor. Sets the Oraclize proof type, and 
     *          initializes the gas price struct with dummy 
     *          values. This standardises the gas cost of the 
     *          __callback function.
     *
     * @param   _gasPrice   Desired gas price for first recursive
     *                      Oraclize call.
     *
     */
    constructor(uint _gasPrice) public payable {
        oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
        nextRecursiveQuery = keccak256('Oraclize Gas Price Oracle');
        gasStationPrices   = GasStationPrices({
            safeLow:     uint64(1234),
            standard:    uint64(1234),
            fast:        uint64(1234),
            timeUpdated: uint64(1)
        });
        recursivelyUpdateGasPrices(0, _gasPrice);
    }
    /**
     * @notice  Allows anyone to update the gas prices stored in 
     *          this contract at any time. Caller must provide 
     *          enough ETH to cover the cost of the Oraclize query. 
     *          If the recursive queries have gone stale the query
     *          made here will automatically begin the recursion 
     *          anew if the fast gas price in the gas prices struct 
     *          is sufficient. The function refunds any excess ETH 
     *          above the price of the Oraclize query to the sender. 
     *
     */
    function updateGasPrices() public payable {
        updateGasPrices(0);
    }
    /**
     * @notice  Allows anyone to update the gas prices stored in 
     *          this contract at any time, with a delay of their 
     *          choosing. Caller must provide enough ETH to cover 
     *          the cost of the Oraclize query. Any extra ETH over
     *          the price of the query is refunded. If the recursive 
     *          queries have gone stale, any query sent with a 0 
     *          delay may become eligible to restart the recursion 
     *          if the fast gas price in the gas prices struct is 
     *          sufficient. This function refunds any excess ETH 
     *          above the price of the Oraclize query to the sender.
     *
     * @param   _delay  The time the callback of the query is desired. 
     *                  Can either be a UTC timestamp, or an offset
     *                  in seconds from now. Delays cannot exceed a 
     *                  maximum of 60 days.
     *
     */
    function updateGasPrices(uint _delay) public payable {
        updateGasPrices(_delay, getFastPrice());
    }
    /**
     * @notice  Allows anyone to update the gas prices stored in 
     *          this contract at any time, with a delay of their 
     *          choosing and a gas price of their choosing. Caller 
     *          must provide enough ETH to cover the cost of the 
     *          Oraclize query. If the recursive queries have gone 
     *          stale, any query sent with a 0 delay and a gas price 
     *          higher than the gas price used in the previous 
     *          recursive query will restart the recursive queries. 
     *          This function returns any exccess ETH above the price 
     *          of the Oraclize query to the sender. 
     *
     * @param   _delay  The time the callback of the query is desired. 
     *                  Can either be a UTC timestamp, or an offset  
     *                  in seconds from now. Delays cannot exceed a  
     *                  maximum of 60 days.
     *
     * @param   _gasPrice   Sets a custom gas price desired for the 
     *                      query, in Wei.
     *
     */
    function updateGasPrices(uint _delay, uint _gasPrice) public payable {
        if (
            _delay == 0 &&
            isRecursiveStale() && 
            _gasPrice >= queryIDs[nextRecursiveQuery].gasPriceUsed + (1 * 10 ** 9) &&
            getQueryPrice(gasLimitRec, _gasPrice) <= msg.value
        ) {
            bool successful = recursivelyUpdateGasPrices(_delay, _gasPrice); // query usable to restart stale recursive ones
            if (successful) {
              queryIDs[nextRecursiveQuery].isRevival = true;
              msg.sender.transfer(msg.value.sub(getQueryPrice(gasLimitRec)));
            }
        } else {
            oraclize_setCustomGasPrice(_gasPrice);
            bytes32 qID = oraclize_query(
              _delay, 
              "computation", 
              [
                "json(QmdKK319Veha83h6AYgQqhx9YRsJ9MJE7y33oCXyZ4MqHE).[safeLow,average,fast]",
                "GET",
                "https://ethgasstation.info/json/ethgasAPI.json"
              ], 
              gasLimit
            );
            queryIDs[qID].isManual = true;
            queryIDs[qID].dueAt = _delay > now 
                ? uint64(_delay) 
                : uint64(now + _delay);
            msg.sender.transfer(msg.value.sub(getQueryPrice(gasLimit)));
        }
    }
    /**
     * @notice  Allows the contract to automatically update the gas prices  
     *          stored herein. Contract balance must be sufficient to 
     *          cover the cost of the Oraclize query. 
     *
     * @param   _delay  The time the callback of the query is desired. 
     *                  Can either be a UTC timestamp, or an offset  
     *                  in seconds from now. Delays cannot exceed a  
     *                  maximum of 60 days.
     *
     * @param   _gasPrice   Sets a custom gas price desired for the 
     *                      query, in Wei.
     *
     * @return  bool    Whether the function call was successful or not.
     *
     */
    function recursivelyUpdateGasPrices(uint _delay, uint _gasPrice) private returns (bool) {
        oraclize_setCustomGasPrice(_gasPrice);
        uint cost = getQueryPrice(gasLimitRec);
        if (address(this).balance < cost && msg.value < cost) {
          emit LogInsufficientBalance();
          return;
        }
        bytes32 qID = oraclize_query(
          _delay, 
          "computation", 
          [
            "json(QmdKK319Veha83h6AYgQqhx9YRsJ9MJE7y33oCXyZ4MqHE).[safeLow,average,fast]",
            "GET",
            "https://ethgasstation.info/json/ethgasAPI.json"
          ], 
          gasLimitRec
        );
        nextRecursiveQuery = qID;
        queryIDs[qID].dueAt = uint64(now + _delay);
        queryIDs[qID].gasPriceUsed = uint128(_gasPrice);
        return true;
    }
    /**
     * @notice  Allows both users and this contract to discover the 
     *          price of the Oraclize query before making it, in 
     *          order to supply the call with the correct amount of ETH.
     *
     * @param   _limit  Gas limit required for the __callback function.
     *
     * @return  uint    The cost of the Oraclize query in Wei.
     *
     */
    function getQueryPrice(uint _limit) public view returns (uint) {
        return oraclize_getPrice("computation", _limit);
    }
    /**
     * @notice  Allows both users and this contract to discover the 
     *          price of the Oraclize query before making it, in 
     *          order to supply the call with the correct amount of ETH.
     *
     * @param   _limit  Gas limit required for the __callback function.
     *
     * @param   _price  Custom gas price for the Oraclize query.
     *
     * @return  uint    The cost of the Oraclize query in Wei.
     *
     */
    function getQueryPrice(uint _limit, uint _price) public view returns (uint) {
        oraclize_setCustomGasPrice(_price);
        return oraclize_getPrice("computation", _limit);
    }
    /**
     * @notice  Checks whether the currently pending recursive Oraclize 
     *          query is past due by greater than 45 minutes or not. 
     *          Should recursion have lapsed, zero delay user queries 
     *          are used to restart the recursion. Such cases are considered 
     *          instantly stale allowing subsequent, higher gas priced 
     *          queries to take priority in restarting recursion.
     *
     * @return  bool    Whether or not the current recursive query is
     *                  past due or replacable.
     *
     */
    function isRecursiveStale() public view returns (bool) {
        return now > queryIDs[nextRecursiveQuery].dueAt + 2700 || 
               queryIDs[nextRecursiveQuery].isRevival;
    }
    /**
     * @notice  Oraclize callback function. Only callable by the
     *          Oraclize address(es). Parses API call result and 
     *          stores it into struct. If query was made manually, 
     *          no further recursive queries are triggered.
     *
     * @param   _myid   Bytes32 ID of the Oraclize query.
     *
     * @param   _result String of the result of the Oraclize query.
     *
     * @param   _proof  Bytes of the proof of the Oraclize query.
     *
     */
    function __callback(bytes32 _myid, string _result, bytes _proof) public {
        require(msg.sender == oraclize_cbAddress(), 'Caller is not Oraclize address!');
        require(!queryIDs[_myid].isProcessed, 'Query has already been processed!');
        if (queryIDs[_myid].dueAt > gasStationPrices.timeUpdated) 
            processUpdate(_myid, _result, _proof);
        queryIDs[_myid].isProcessed = true;
        if (!queryIDs[_myid].isManual && _myid == nextRecursiveQuery) 
            recursivelyUpdateGasPrices(getDelayToNextInterval(), getFastPrice()); 
    }
    /**
     * @notice  Function processes the result string of the Oraclize
     *          query. Splices string into its constituent parts and 
     *          parses the gas prices into the desired uints.
     *
     *
     * @dev     The vars are returning struct types from the strings 
     *          library. They give deprecation warnings but we have 
     *          no other option. Note also the mutable nature of 
     *          split().
     *
     * @param   _myid   Bytes32 ID of the Oraclize query.
     *
     * @param   _result String of the result of the Oraclize query.
     *
     * @param   _proof  Bytes of the proof of the Oraclize query.
     *
     */
    function processUpdate(bytes32 _myid, string _result, bytes _proof) private {
        var delim = ",".toSlice();
        var stringToParse = _result.toSlice();
        uint64 l = uint64(parseInt(stringToParse.split(delim).toString()));
        uint64 s = uint64(parseInt(stringToParse.split(delim).toString()));
        uint64 f = uint64(parseInt(stringToParse.split(delim).toString()));
        gasStationPrices = GasStationPrices({
            safeLow: l,
            standard: s,
            fast: f,
            timeUpdated: queryIDs[_myid].dueAt
        });
        emit LogGasPricesUpdated(l, s, f, _myid, _proof);
    }
    /**
     * @notice  Get the safe low gas price in Wei.
     *
     * @return  uint
     *
     */
    function getSafeLowPrice() public view returns (uint) {
        return gasStationPrices.safeLow.mul(conversionFactor);
    }
    /**
     * @notice  Get the standard gas price in Wei.
     *
     * @return  uint
     *
     */
    function getStandardPrice() public view returns (uint) {
        return gasStationPrices.standard.mul(conversionFactor);
    }
    /**
     * @notice  Get the fast gas price in Wei.
     *
     * @return  uint
     *
     */
    function getFastPrice() public view returns (uint) {
        return gasStationPrices.fast.mul(conversionFactor);
    }
    /**
     * @notice  Returns the time the gas prices were last updated,
     *          as a UTC timestamp.
     *
     */
    function getLastUpdated() public view returns (uint) {
        return gasStationPrices.timeUpdated;
    }
    /**
     * @notice  Returns all three gas prices, ordered slowest to 
     *          fastest, plus the time at which they were updated.
     *
     * @return  uint    The safe low gas price in Wei.
     *          uint    The standard gas price in Wei.
     *          uint    The fast gas price in Wei.
     *          uint    Timestamp of last update
     *
     */
    function getGasPrices() public view returns (uint, uint, uint, uint) {
        return (
            getSafeLowPrice(),
            getStandardPrice(),
            getFastPrice(),
            getLastUpdated()
        );
    }
    /**
     * @notice  Calculates the delay in seconds to the next occuring 
     *          sixth hour. If delay is fewer than 600 seconds, the 
     *          delay until the subsequent 6th hour mark is used instead.
     *  
     * @return  uint    Time in seconds to next sixth hour.
     *
     */
    function getDelayToNextInterval() public view returns (uint) {
        uint secs         = now % 60;
        uint mins         = (now / 60) % 60;
        uint hour         = (now / 60 / 60) % 24;
        uint secsElapsed  = ((hour * 60 * 60) + (mins * 60) + secs);
        uint secsInPeriod = (((hour / interval) + 1) * interval) * 60 * 60;
        uint remaining    = secsInPeriod - secsElapsed;
        return remaining > 600 
            ? remaining 
            : remaining + (interval * 60 * 60);
    }
    /**
     * @notice  Fallback function allowing ETH addition by
     *          anyone.
     *
     */
     function () public payable {}
}
