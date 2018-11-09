const Web3 = require('web3')
const {waitForEvent} = require('./utils')
const bitcoinExample = artifacts.require('./BitcoinBalanceExample.sol')
const web3 = new Web3(new Web3.providers.WebsocketProvider('ws://localhost:9545'))

contract('Bitcoin Address Example Tests', () => {

  let balance

  beforeEach(async () => (
    {contract} = await bitcoinExample.deployed(), 
    {methods, events} = new web3.eth.Contract(contract._jsonInterface, contract._address) 
  ))

  it('Should retrieve a balance from the bitcoin blockchain', async () => {
    const {returnValues:{_balance}} = await waitForEvent(events.LogBitcoinAddressBalance)
    balance = _balance
    assert.isAbove(parseInt(balance), 0, 'No balance was retrieved from the bitcoin blockchain!')
  })

  it('Should store the bitcoin balance in the smart-contract', async () => {
    const amount = await methods.balance().call()
    assert.isTrue(parseInt(amount) === parseInt(balance), 'Bitcoin balance was not stored in the smart-contract!')
  })
})
