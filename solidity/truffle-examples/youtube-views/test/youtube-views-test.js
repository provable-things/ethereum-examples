const Web3 = require('web3')
const {PREFIX, waitForEvent} = require('./utils')
const youtubeViews = artifacts.require('./YoutubeViews.sol')
const web3 = new Web3(new Web3.providers.WebsocketProvider('ws://localhost:9545'))

contract('Youtube Views Tests', accounts => {

  let loggedViews
  const gasAmt = 3e6
  const address = accounts[0]
  
  beforeEach(async () => (
    {contract} = await youtubeViews.deployed(), 
    {methods, events} = new web3.eth.Contract(contract._jsonInterface, contract._address) 
  ))

  it('Should have logged a new Oraclize query', async () => {
    const {returnValues:{description}} = await waitForEvent(events.LogNewOraclizeQuery)
    assert.equal(description, 'Oraclize query was sent, standing by for the answer...', 'Oraclize query incorrectly logged!')
  })

  it('Callback should have logged a new YouTube views event', async () => {
    const {returnValues:{views}} = await waitForEvent(events.LogYoutubeViewCount)
    loggedViews = views 
    assert.isAbove(parseInt(views), 0,'A view count should have been retrieved from Oraclize call!')
  })

  it('Should store YouTube views correctly in contract', async () => {
    const queriedViews = await methods.viewsCount().call()
    assert.equal(queriedViews, loggedViews, 'Contract\'s views are not set correctly!')
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
