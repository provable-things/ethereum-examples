# :wrench: :construction: Testing Oraclize's Random Example.

&nbsp;

This repo is to demonstrate how you would set up an Oraclize smart-contract development environment using Truffle to do most of the heavy lifting for you. Head on over to the `./test` folder to examine the javascript files that thoroughly test the smart-contract, which latter you will find in `./contracts`.

## :page_with_curl:  _Instructions_

The random datasource is currently available on the Ethereum mainnet and on some Ethereum public testnets only (Rinkeby, Kovan, and Ropsten Revival); and it is not integrated yet with private blockchains/testrpc/browser-solidity-vmmode, so you will need to get a mnemonic passphrase and an infura key to make the example work.

**1)** Go on the Infura website to get an Infura key: [infura.io](https://infura.io). The key is a 32 HEX characters string

**2)** Get a mnemonic passphrase, an easy way is to get a Metamask one: [metamask.io](https://metamask.io/)

**3)** Fire up your favourite console & clone this repo somewhere:

__`❍ git clone https://github.com/oraclize/ethereum-examples.git`__

**4)** Enter this directory & install dependencies:

__`❍ cd ethereum-examples/solidity/truffle-examples/random-datasource && npm install`__

**5)** In `ethereum-examples/solidity/truffle-examples/random-datasource`, create a new file `apikeys.js` or `.env` and add the mnemonic passphrase and the Infura key to it, such as:

```javascript
// apikeys.js example

module.exports = {
  mnemonic: 'word1 word2 word3 word4 word5 word6 word7 word8 word9 word10 word11 word12',
  infuraKey: '0123456789abcdef0123456789abcdef'
}
```

or

```
// .env example

mnemonic = 'word1 word2 word3 word4 word5 word6 word7 word8 word9 word10 word11 word12'
infuraKey = '0123456789abcdef0123456789abcdef'
```

**6)** Compile with Truffle:

__`❍ npx truffle compile`__

**7)** Test the contract with Truffle leveraging a testnet, such as Rinkeby:

__`❍ npx truffle test --network rinkeby`__

&nbsp;

## :camera: Passing Tests:

[The passing tests!](random-datasource-tests.jpg)

&nbsp;

## :black_nib: Notes:

__❍__ Note that your own Infura key and the Metamask passphrase must be kept secure. The ones provided here are simply placeholders.

__❍__ If you have any issues, head on over to our [Gitter](https://gitter.im/oraclize/ethereum-api?raw=true) channel to get timely support!

__*Happy developing!*__

