const Web3 = require('web3')
const { waitForEvent } = require('./utils')
const kraken = artifacts.require('./KrakenPriceTicker.sol')
const web3 = new Web3(new Web3.providers.WebsocketProvider('ws://localhost:9545'))

contract('Kraken Price Ticker Tests', accounts => {

  let priceETHXBT
  const gasAmt = 3e6
  const address = accounts[0]

  beforeEach(async () => (
    { contract } = await kraken.deployed(),
    { methods, events } = new web3.eth.Contract(
      contract._jsonInterface,
      contract._address
    )
  ))

  it('Should log a new Oraclize query', async () => {
    const {
      returnValues: {
        description
      }
    } = await waitForEvent(events.LogNewOraclizeQuery)
    assert.strictEqual(
      description,
      'Oraclize query was sent, standing by for the answer...',
      'Oraclize query incorrectly logged!'
    )
  })

  it('Callback should log a new ETHXBT price', async () => {
    const {
      returnValues: {
        price
      }
    } = await waitForEvent(events.LogNewKrakenPriceTicker)
    priceETHXBT = price
    assert.isAbove(
      parseFloat(price),
      0,
      'A price should have been retrieved from Oraclize call!'
    )
  })

  it('Should set ETHXBT price correctly in contract', async () => {
    const queriedPrice = await methods
      .priceETHXBT()
      .call()
    assert.strictEqual(
      priceETHXBT,
      queriedPrice,
      'Contract\'s ETHXBT price not set correctly!'
    )
  })

  it('Should log a failed query due to lack of funds', async () => {
    const { events } = await methods
      .update()
      .send({
        from: address,
        gas: gasAmt
      })
    const description = events.LogNewOraclizeQuery.returnValues.description
    assert.strictEqual(
      description,
      'Oraclize query was NOT sent, please add some ETH to cover for the query fee!',
      'Oraclize query incorrectly logged!'
    )
  })
})
