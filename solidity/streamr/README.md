### Using streamr with Oraclize

Streamr allows you to publish continuous datastreams and interact with them. Using Oraclize, you may import these streams to Ethereum.

#### StreamrTweetsCounter.sol

> count BTC-specific tweets since query request

Utilizes Oraclize's computation datasource and subscribes to streamr's public `BTC Tweets` using the `streamr-client` via websockets. The computation archive is available in the `comp-archive` directory for inspection. By leveraging the computation datasource and pairing it with a datastream from streamr, you are able to emulate a streamr canvas backed by authenticity proofs right on the blockchain.

The computation query, within the contract, takes a duration parameter. Currently hardcoded as 1, which is equivalent to 1 minute. This can be changed, but note that Oraclize computation instances have a time limit on them, so ensure any value used is below the time limit set (for up to date time limit, refer to the general Oraclize documentation).
