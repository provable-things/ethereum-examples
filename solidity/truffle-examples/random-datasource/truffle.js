const fs = require('fs')
const path = require('path')
const API_PATH = path.join(__dirname, 'apikeys.js')
const HDWalletProvider = require("truffle-hdwallet-provider");

const fileExists = _path => fs.existsSync(_path)

const getExternalVariable = _variable => fileExists(API_PATH)
  ? require(API_PATH)[_variable]
  : process.env[_variable]
  ? process.env[_variable]
  : (console.log(`Cannot migrate! Please provide '${_variable}' as an environment variable, or export it from '${API_PATH}'!`), process.exit(1))

module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*",
      websockets: true
	},
    ropsten: {
      provider: () => new HDWalletProvider(getExternalVariable('mnemonic'), `https://ropsten.infura.io/v3/${getExternalVariable('infuraKey')}`),
      network_id: 3,
      gas: 55e5, // Ropsten has a lower block limit than mainnet
      gasPrice: 20e9,
      websockets: true
    },
    rinkeby: {
      provider: () => new HDWalletProvider(getExternalVariable('mnemonic'), `https://rinkeby.infura.io/v3/${getExternalVariable('infuraKey')}`),
      network_id: 4,
      gas: 6e6,
      gasPrice: 5e9,	
      websockets: true
    },
    kovan: {
      provider: () => new HDWalletProvider(getExternalVariable('mnemonic'), `https://kovan.infura.io/v3/${getExternalVariable('infuraKey')}`),
      network_id: 42,
      gas: 8e6,
      gasPrice: 20e9,
      websockets: true
    }
  },
  compilers: {
    solc: {
      version: '0.5.0',
      settings: {
        optimizer: {
          enabled: true, // Default: false
          runs: 0 // Default: 200
        }
      }
    }
  }
}
