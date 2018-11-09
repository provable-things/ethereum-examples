const Web3 = require('web3')
const {PREFIX, waitForEvent} = require('./utils')
const diesel = artifacts.require('./DieselPrice.sol')
const web3 = new Web3(new Web3.providers.WebsocketProvider('ws://localhost:9545'))

contract('Diesel Price Tests', accounts => {

  let contractPrice
  const gasAmt = 3e6
  const address = accounts[0]

  beforeEach(async () => (
    {contract} = await diesel.deployed(), 
    {methods, events} = new web3.eth.Contract(contract._jsonInterface, contract._address) 
  ))

  it('Should have logged a new Oraclize query', async () => {
    const {returnValues:{description}} = await waitForEvent(events.LogNewOraclizeQuery)
    assert.equal(description, 'Oraclize query was sent, standing by for the answer...', 'Oraclize query incorrectly logged!')
  })

  it('Callback should have logged a new diesel price', async () => {
    const {returnValues:{price}} = await waitForEvent(events.LogNewDieselPrice)
    contractPrice = price * 100
    assert.isAbove(parseInt(price), 0, 'A price should have been retrieved from Oraclize call!')
  })

  it('Should set diesel price correctly in contract', async () => {
    const queriedPrice = await methods.dieselPriceUSD().call()
    assert.equal(contractPrice, queriedPrice, 'Contract\'s diesel price not set correctly!')
  })

  it('Should revert on second query attempt due to lack of funds', async () => {
    const expErr = 'revert'
    try {
      await methods.update().send({from: address, gas: gasAmt})
      assert.fail('Update transaction should not have succeeded!')
    } catch (e) {
      assert.isTrue(e.message.startsWith(`${PREFIX}${expErr}`), `Expected ${expErr} but got ${e.message} instead!`)
    }
  })
})
