/*
    Utilizies computation datasource

    Provides a fully featured HTTP library by way of the Python requests module,
    allowing custom headers, auth etc... to be used as kwargs. Refer to
    http://docs.python-requests.org/en/latest/api/ for full feature list
*/
pragma solidity ^0.4.0;

import "./oraclizeAPI.sol";

contract UrlRequests is usingOraclize {

    event newOraclizeQuery(string description);
    event LogResult(string result);
 
    function UrlRequests() payable {
        //oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
    }

    function __callback(bytes32 myid, string result) {
        if (msg.sender != oraclize_cbAddress()) throw;
        emit LogResult(result);
    }

    function request(string _query, string _method, string _url, string _kwargs) payable {
        if (oraclize_getPrice("computation") > this.balance) {
            newOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            newOraclizeQuery("Oraclize query was sent, standing by for the answer...");
            oraclize_query("computation",
                [_query,
                _method,
                _url,
                _kwargs]
            );
        }
    }
    // sends a custom content-type in header and returns the header used as result
    // wrap first arguement of computation ds with helper needed, such as json in this case
    function requestCustomHeaders() payable {
        request("json(QmdKK319Veha83h6AYgQqhx9YRsJ9MJE7y33oCXyZ4MqHE).headers",
                "GET",
                "http://httpbin.org/headers",
                "{'headers': {'content-type': 'json'}}"
                );
    }

    function requestBasicAuth() payable {
        request("QmdKK319Veha83h6AYgQqhx9YRsJ9MJE7y33oCXyZ4MqHE",
                "GET",
                "http://httpbin.org/basic-auth/myuser/secretpass",
                "{'auth': ('myuser','secretpass'), 'headers': {'content-type': 'json'}}"
                );
    }

    function requestPost() payable {
        request("QmdKK319Veha83h6AYgQqhx9YRsJ9MJE7y33oCXyZ4MqHE",
                "POST",
                "https://api.postcodes.io/postcodes",
                '{"json": {"postcodes" : ["OX49 5NU"]}}'
                );
    }

    function requestPut() payable {
        request("QmdKK319Veha83h6AYgQqhx9YRsJ9MJE7y33oCXyZ4MqHE",
                "PUT",
                "http://httpbin.org/anything",
                "{'json' : {'testing':'it works'}}"
                );
    }

    function requestCookies() payable {
        request("QmdKK319Veha83h6AYgQqhx9YRsJ9MJE7y33oCXyZ4MqHE",
                "GET",
                "http://httpbin.org/cookies",
                "{'cookies' : {'thiscookie':'should be saved and visible :)'}}"
                );
    }
}
