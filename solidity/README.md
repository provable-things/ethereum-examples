## __Solidity Examples__

Here you can find various Solidity examples showing how to use the __Oraclize API__ in your smart-contracts. Simply copy one of the __`.sol`__ files into the [__Remix IDE__](remix.ethereum.org) online Solidity compiler to see them in action! Then fire up the [__Oraclize-Plugin__](https://blog.oraclize.it/built-for-developers-21e414ad2841) (which you'll find under the settings tab) and you'll be able to see your __Oraclize__ queries working in real time!

Alternatively, if you prefer to develop locally, browse into the __`truffle-examples`__ directory to see how __Oraclize__ works in a [__Truffle__](https://www.truffleframework.com/) development environment. Each self-contained example comes with full test coverage so you can see how to create robust, data-rich smart-contracts that leverage the __Oraclize__ service fully.

:computer: __Happy developing!__

***

### :black_nib: __Notes__

This is a list of the features you will find amongst the examples, along with a reference to the relevant example:

* Sending simple __URL Queries!__ [#1](./DieselPrice.sol)
* Scheduling a query for a __future date__! [#1](./KrakenPriceTicker.sol)
* Sending calls __recursively__! [#1](./KrakenPriceTicker.sol)
* Requesting a __TLSNotary__ authenticity __proof!__ [#1](./computation-datasource/delegated-math/DelegatedMath.sol)
* Requesting an __Android__ authenticity __proof!__ [#1](./KrakenPriceTicker.sol)
* Leveraging __JSONPATH__ parsing helpers! [#1](./KrakenPriceTicker.sol)
* Leveraging __XPATH__ parsing helpers! [#1](./DieselPricePeg.sol)  [#2](./YoutubeViews.sol)
* Using the __computation datasouce__! [#1](./computation-datasource/url-requests/urlRequests.sol) [#2](./computation-datasource/streamr/StreamrTweetsCounter.sol)
* Using the __WolframAlpha__ datasource! [#1](./WolframAlpha.sol)

__Coming Soon!__

* Nested queries!
* Full query encryption!
* Partial query encryption!
* Leveraging BINARY_SLICE parsing helpers!

***

### :loudspeaker: __Support__

If you need any help working with the examples here, you can get timely support in the [__Oraclize Gitter__](https://gitter.im/oraclize) channel.
