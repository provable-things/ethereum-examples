# :wrench: :construction: Testing Oraclize's Random Example.

&nbsp;

This repo is to demonstrate how you would set up an Oraclize smart-contract development environment using Truffle to do most of the heavy lifting for you. Head on over to the `./test` folder to examine the javascript files that thoroughly test the smart-contract, which latter you will find in `./contracts`.

## :page_with_curl:  _Instructions_

Since the random datasource is currently available on the Ethereum mainnet and on all Ethereum public testnets only (Rinkeby, Kovan, Ropsten-revival); and it is *not integrated yet with private blockchains/testrpc/browser-solidity-vmmode*, you will need to **get a mnemonic passphrase and an infura key** to make the example work.

**A)** Go on the infura website to get an infura key: (https://infura.io)[infura.io]
The key is a 32 hexadecimal character string.

**B)** Get a mnemonic passphrase, an easy way is to get the Metamask one:
(https://metamask.io/)[metamask.io]

**C)** Create a new file `apikeys.js` or `.env` and add the mnemonic passphrase and the infura key to it, such as:

```javascript
// apikeys.js example

module.exports = {
  mnemonic: 'word1 word2 word3 word4 word5 word6 word7 word8 word9 word10 word11 word12'
  infuraKey: '0123456789abcdef0123456789abcdef'
}
```

Please note that those must be kept secure and the one provided here are just to help the user with the tutorial.

---

Then you can proceed with the following console instructions:

**1)** Fire up your favourite console & make sure you have Truffle globally 5 installed:

__`❍ npm install -g truffle@5:`__

**2)** Clone this repo somewhere:

__`❍ git clone https://github.com/oraclize/ethereum-examples.git`__

**3)** Enter this directory & install dependencies:

__`❍ cd ethereum-examples/solidity/truffle-examples/random-datasource && npm install`__

**4)** Compile with Truffle:

__`❍ truffle compile`__

**5)** Test the contract with Truffle leveraging a testnet, such as Rinkeby:

__`❍ truffle test --network rinkeby`__

&nbsp;

## :camera: Passing Tests:

[The passing tests!](random-datasource-test.jpg)

&nbsp;

## :black_nib: Notes:

__❍__ If you have any issues, head on over to our [Gitter](https://gitter.im/oraclize/ethereum-api?raw=true) channel to get timely support!

__*Happy developing!*__
