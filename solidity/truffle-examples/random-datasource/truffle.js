const {
  fileExists,
  getExternalVariable,
} = require('./test/utils.js')

const path = require('path')
const API_PATH = path.resolve(__dirname, 'apikeys.js')
const HDWalletProvider = require("truffle-hdwallet-provider")

require('dotenv').config()

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
      gas: 47e5,
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
