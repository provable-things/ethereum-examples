## Oraclize *random datasource* Solidity example

> Note: the *random datasource* is currently available on the **Ethereum mainnet and on all Ethereum public testnets only** (Rinkeby, Kovan, Ropsten-revival) - it is not integrated yet with private blockchains/testrpc/browser-solidity-vmmode.

This folder contains a Solidity example contract code showing how the Oraclize *random datasource* can be used on Ethereum.

The rationale behind this method of securely feeding off-chain randomness into the blockchain is explained in the [“A Scalable Architecture for On-Demand, Untrusted Delivery of Entropy”](http://www.oraclize.it/papers/random_datasource-rev1.pdf) whitepaper.

The design described there prevents Oraclize from tampering with the random results coming from the Trusted Execution Envirnment (TEE) and protects the user from a number of attack vectors.

The authenticity proof, attached with the result, can be easily verified not just off-chain but even by any Solidity contract receiving them. The example presented here, showing how to integrate the verification process, discards any random result whose authenticity proofs don't pass the verification process.

The *randon datasource* is leveraging the *Ledger proof*, first introduced [in this blogpost](https://blog.oraclize.it/welcoming-our-brand-new-ledger-proof-649b9f098ccc), to prove that the origin of the generated randomness is really a secure Ledger device.

The CODEHASH, i.e. SHA256 of the application's binary, which is hardcoded in the smart contract as part of the verification process, can be used by anybody to ensure that the application code (to be released next week, as it is being polished to increase its readability) is really the one being executed to generate the randomness.




**Returned proof format**


| 1 | 2 | 3 | 4 | 5 | 6| 7 | 8 | 9 | 10 | 11 |
| ------------- |-------------| -----| ------------- |-------------| -----| ------------- |-------------| -----| ------------- |-------------|
| 3 bytes | 65 bytes | var length | 32 bytes | 32 bytes | 8 bytes | 1 byte | 32 bytes | var length | 65 bytes | var length |
| 'LP\x01' (prefix) | APPKEY1 PubKey | APPKEY1 cert (CA:Ledger) | CODEHASH | keyhash | timelock | Nbytes | user nonce | SessionKey sig | SessionPubKey |  attestation sig |



**Verification Steps**


- Step 1: the prefix has to match 'LP\x01' (Ledger Proof version 1)
- Step 2: the unique keyhash has to match with the sha256 of (context name + queryId)
- Step 3: we assume sig1 is valid (it will be verified during step 5) and we verify if 'result' is the prefix of sha256(sig1)
- Step 4: commitment match verification, sha3(delay, nbytes, unonce, sessionKeyHash) == commitment in storage.
- Step 5: validity verification for sig1 (keyhash and args signed with the sessionKey)
- Step 6: verify the attestation signature, APPKEY1 must sign the sessionKey from the correct ledger app (CODEHASH)
- Step 7: verify the APPKEY1 provenance (must be signed by Ledger)
