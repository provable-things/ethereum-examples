# :construction: Provable: Caller Pays For Query Example

A Provable/Truffle example showing how you can require the contract caller to provide the ETH to cover the Provable query cost!

This repo is set up to show how a Provable smart-contract development environment using Truffle alongside the __`ethereum-bridge`__ might look. Head on over to the `./test` folder to examine the javascript files that thoroughly test the smart-contract, which latter you will find in `./contracts`.

## :wrench: _Run the tests:_

**1)** Fire up your favourite console & clone this repo somewhere:

__`❍ git clone https://github.com/provable-things/ethereum-examples.git`__

**2)** Enter this directory & install dependencies:

__`❍ cd ethereum-examples/solidity/truffle-examples/caller-pays-for-query && npm i`__

**3)** Launch the Truffle development console:

__`❍ npx truffle develop`__

**4)** Open a _new_ console in the same directory & spool up the ethereum-bridge:

__`❍ npx ethereum-bridge -a 9 -H 127.0.0.1 -p 9545 --dev`__

**5)** Once the bridge is ready & listening, go back to the first console with Truffle running & set the tests going!

__`❍ truffle(develop)> test`__

&nbsp;

## :camera: Passing Tests:

```javascript

  Contract: ❍ Provable Truffle Examples:
    ❍ Caller-pays-for-query tests
      ✓ Should get contract methods & events
      ✓ Should be able to call `queryPrice` public getter
      ✓ Contract balance should be 0
      ✓ Query price should be > 0
      ✓ User cannot make query if msg.value === 0 (43ms)
      ✓ User cannot make query if msg.value < query cost
      ✓ User can make query if msg.value === query cost
      ✓ Query should have emitted event with ETH price in USD (11676ms)
      ✓ Eth price in USD should be saved in contract
      ✓ User should get refund when making query but sending > query cost (121ms)


  10 passing (12s)


```

&nbsp;

## :black_nib: Notes:

__❍__ If you have any issues, head on over to our [Gitter](https://gitter.im/oraclize/ethereum-api?raw=true) channel to get timely support!

__*Happy developing!*__
