# :wrench: :construction: Testing Provable's Encrypted Query Example.

&nbsp;

This repo is to demonstrate how you would set up a Provable smart-contract development environment using Truffle & the Ethereum-Bridge to do most of the heavy lifting for you. Head on over to the `./test` folder to examine the javascript files that thoroughly test the smart-contract, which later you will find in `./contracts`.

## :squirrel: _Query Encryption_

**1)** Decide on the Provable query you want to encrypt, the one in this example is:

```
oraclize_query(
  "URL",
  "json(https://api.postcodes.io/postcodes).status",
  '{"postcodes" : ["OX49 5NU", "M32 0JG", "NE30 1DP"]}'
)
```

**2)** Fire up your favourite console & clone the Provable encyption tool repo somewhere:

__`❍ git clone https://github.com/provable-things/encrypted-queries.git`__

**3)** Enter the directory and brace yourself to encrypt your query with the Provable public key:

__`❍ cd encrypted-queries`__

Provable public key:

```
044992e9473b7d90ca54d2886c7addd14a61109af202f1c95e218b0c99eb060c7134c4ae46345d0383ac996185762f04997d6fd6c393c86e4325c469741e64eca9
```

**4)** Encrypt the first query argument:

__`❍  python encrypted_queries_tools.py -e -p 044992e9473b7d90ca54d2886c7addd14a61109af202f1c95e218b0c99eb060c7134c4ae46345d0383ac996185762f04997d6fd6c393c86e4325c469741e64eca9 "json(https://api.postcodes.io/postcodes).status"`__

that returns a non-determinist result:

```
BMqMhIFTTzsDbUSfPT233dVWB6wp0ksci7R/c6Jezcy3nEsnX7EQTaqRbej3shF7NlOwGRJAs1IBtYS32f6HrexffY+z1XMCHp+W6vFaIpDSVP0sVxiokuO0fr+ePxHOkvUh9x49BSmageBbHM1RB6QY/xhhvwJtssZOspEHvic=
```

**5)** Encrypt the second query argument:

__`❍  python encrypted_queries_tools.py -e -p 044992e9473b7d90ca54d2886c7addd14a61109af202f1c95e218b0c99eb060c7134c4ae46345d0383ac996185762f04997d6fd6c393c86e4325c469741e64eca9 '{"postcodes" : ["OX49 5NU", "M32 0JG", "NE30 1DP"]}'`__

returning yet another unique encrypted string you will put in place of the plain text query:

```
BDfT0gaCqtru/YRL/qEDEPTopcKe04wXtkRlDw0PNa8hazsDgKXv1G0pBVaHK5um6eTzAggrLKlXVLSUqI6rVzd9oaDST4Zo1NtLf2iMwWI0yx7sWwuhFY0Ot+OltgHLf8SclyRuHZHiOq+Ubx1pBtFGImYH4yMon1PgR+V9iWqN2gzv
```

**6)** Use the previous two non-deterministic outputs and plug them into the query function:

```
oraclize_query(
  "URL",
  "BMqMhIFTTzsDbUSfPT233dVWB6wp0ksci7R/c6Jezcy3nEsnX7EQTaqRbej3shF7NlOwGRJAs1IBtYS32f6HrexffY+z1XMCHp+W6vFaIpDSVP0sVxiokuO0fr+ePxHOkvUh9x49BSmageBbHM1RB6QY/xhhvwJtssZOspEHvic=",
  "BDfT0gaCqtru/YRL/qEDEPTopcKe04wXtkRlDw0PNa8hazsDgKXv1G0pBVaHK5um6eTzAggrLKlXVLSUqI6rVzd9oaDST4Zo1NtLf2iMwWI0yx7sWwuhFY0Ot+OltgHLf8SclyRuHZHiOq+Ubx1pBtFGImYH4yMon1PgR+V9iWqN2gzv"
);
```

&nbsp;

## :page_with_curl:  _Instructions_

**1)** Fire up your favourite console & clone this repo somewhere:

__`❍ git clone https://github.com/provable-things/ethereum-examples.git`__

**2)** Enter this directory & install dependencies:

__`❍ cd ethereum-examples/solidity/truffle-examples/encrypted-query && npm install`__

**3)** Launch Truffle:

__`❍ npx truffle develop`__

**4)** Open a _new_ console in the same directory & spool up the ethereum-bridge:

__`❍ npx ethereum-bridge -a 9 -H 127.0.0.1 -p 9545 --dev`__

**5)** Once the bridge is ready & listening, go back to the first console with Truffle running & set the tests going!

__`❍ truffle(develop)> test`__

&nbsp;

## :camera: Passing Tests:

[The passing tests!](encrypted-query.png)

&nbsp;

## :black_nib: Notes:

__❍__ If you have any issues, head on over to our [Gitter](https://gitter.im/provable/ethereum-api?raw=true) channel to get timely support!

__*Happy developing!*__
