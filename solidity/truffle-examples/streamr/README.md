# :wrench: :construction: Testing Provable's Streamr Tweets Example.

&nbsp;

This repo is to demonstrate how you would set up a Provable smart-contract development environment using Truffle & the Ethereum-Bridge to do most of the heavy lifting for you. Head on over to the `./test` folder to examine the javascript files that thoroughly test the smart-contract, which latter you will find in `./contracts`.

## :page_with_curl:  _Instructions_

**1)** Fire up your favourite console &  clone this repo somewhere:

__`❍ git clone https://github.com/provable-things/ethereum-examples.git`__

**2)** Enter this directory & install dependencies:

__`❍ cd ethereum-examples/solidity/truffle-examples/streamr && npm install`__

**3)** Launch Truffle:

__`❍ npx truffle develop`__

**4)** Open a _new_ console in the same directory & spool up the ethereum-bridge:

__`❍ npx ethereum-bridge -a 9 -H 127.0.0.1 -p 9545 --dev`__

**5)** Once the bridge is ready & listening, go back to the first console with Truffle running & set the tests going!

__`❍ truffle(develop)> test`__

&nbsp;

## :camera: Passing Tests:

[The passing tests!](streamr-tests.jpg)

&nbsp;

## :black_nib: Notes:

__❍__ If you have any issues, head on over to our [Gitter](https://gitter.im/oraclize/ethereum-api?raw=true) channel to get timely support!

__*Happy developing!*__
