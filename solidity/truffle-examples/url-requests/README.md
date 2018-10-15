# :wrench: :construction: Testing Oraclize's Url-Requests Example.

&nbsp;

This repo is to demonstrate how you would set up an Oraclize smart-contract development environment using Truffle & the Ethereum-Bridge to do most of the heavy lifting for you. Head on over to the `./test` folder to examine the javascript files that thoroughly test the smart-contract, which latter you will find in `./contracts`.

## :page_with_curl:  _Instructions_

**1):** Fire up your favourite console & make sure you have Truffle 5 installed:

__`❍ npm install -g truffle@beta`__

**2)** Clone this repo somewhere:

__`❍ git clone https://github.com/oraclize/ethereum-examples.git`__

**3)** Enter this directory & install dependencies:

__`❍ cd ethereum-examples/truffle-examples/url-requests && npm install`__

**4)** Launch Truffle:

__`❍ truffle develop`__

**5)** Open a _new_ console in the same directory & spool up the ethereum-bridge:

__`❍ ./node_modules/.bin/ethereum-bridge -a 9 -H 127.0.0.1 -p 9545 --dev`__

**6)** Once the bridge is ready & listening, go back to the first console with Truffle running & set the tests going!

__`❍ test`__

&nbsp;

## :camera: Passing Tests:

[The passing tests!](https://github.com/oraclize/ethereum-examples/solidity/truffle-examples/url-requests/url-requests-tests.jpg)

&nbsp;

## :black_nib: Notes:

__❍__ The computation data-source combined with the ethereum-bridge in a development environment can make for a slightly slower than usual response time for the Oraclize `__callback` - please be patient whilst this occurs!

__❍__ Note also that the `UrlRequests.sol` smart-contract in `./contracts` has the proof-type commented out in the constructor. This is because the TLS-Notary proof is disabled on test-nets due to abuse. Using Oraclize on the ethereum main-net _without_ proofs is _not_ recommended, so don't forget to re-enable them for live deployments!  

__❍__ If you have any further issues, head on over to our [Gitter](https://gitter.im/oraclize/ethereum-api?raw=true) channel to get timely support!

__*Happy developing!*__
