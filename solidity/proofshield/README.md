## Oraclize *ProofShield* Solidity example

> Note: the *ProofShield* is currently available on **all Ethereum public testnets only** (Rinkeby, Kovan, Ropsten-revival) - it is not integrated yet with private blockchains/testrpc/browser-solidity-vmmode.

This folder contains a Solidity example contract code showing how the *ProofShield* can be used on Ethereum.

This code is *experimental*, please DO NOT use this in production. A production-ready version will follow in the future.

This example code shows how the ProofShield makes it possible to verify on-chain the Oraclize authenticity proofs: this ensures that the data Oraclize sends back to the contract is indeed authentic, before using it.

The additional gas cost to check the proof on-chain is approximately 60k gas.
