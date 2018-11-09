const HDWalletProvider   = require("truffle-hdwallet-provider")

// Note: If deploying to a live network, please provide a mnemonic & infura apikey.

const apikey = ''
const mnemonic = ''

module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*",
      websockets: true
    },
    mainnet: {
      provider: () => new HDWalletProvider(mnemonic, `https://mainnet.infura.io/${apikey}`),
      network_id: '1',
      gas: 3e6,
      gasPrice: 20e9
    },
    ropsten: {
      provider: () => new HDWalletProvider(mnemonic, `https://ropsten.infura.io/${apikey}`),
      network_id: '3',
      gas: 47e5,
      gasPrice: 20e9
    },
    rinkeby: {
      provider: () => new HDWalletProvider(mnemonic, `https://rinkeby.infura.io/${apikey}`),
      network_id: '4',
      gas: 3e6,
      gasPrice: 20e9
    }
  },
  solc: {
    settings: {
      optimizer: {
        enabled: true
      }
    }
  },
  compilers: {
    solc: {
      version: '0.4.24'
    }
  }
}