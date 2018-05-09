

## ethereum-examples [![Join the chat at https://gitter.im/oraclize/ethereum-api](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/oraclize/ethereum-api?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge) [![Docs@Oraclize.it](https://camo.githubusercontent.com/5e89710c6ae9ce0da822eec138ee1a2f08b34453/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f646f63732d536c6174652d627269676874677265656e2e737667)](http://docs.oraclize.it) [![Contributions Welcome!](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)](https://github.com/dwyl/esta/issues) [![HitCount](http://hits.dwyl.io/oraclize/ethereum-examples.svg)](http://hits.dwyl.io/oraclize/ethereum-examples)

Here you can find some code examples showing how *easy* integrating the [Oraclize Ethereum API](https://github.com/oraclize/ethereum-api) is.

Thanks to our [Ethereum API helpers](https://github.com/oraclize/ethereum-api) using Oraclize in your Solidity/Serpent code is very easy.

In Solidity it is as simple as inheriting the `usingOraclize` contract: this will provide you some functions, like `oraclize_query`, which make it trivial to leverage our technology straight away.

If you are using Serpent just import `oraclizeAPI.se` and enjoy the same Oraclize helper functions via macros!
###### IMPORTANT NOTICE:

It is highly recommended to avoid using serpent, especially in production. The examples have been left for historical reasons but support for it is no longer maintained as serpent is considered outdated and audits have shown it to be flawed.
