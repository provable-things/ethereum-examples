const Web3 = require('web3')
const swarm = artifacts.require('./Swarm.sol')
const {PREFIX, waitForEvent} = require('./utils')
const web3 = new Web3(new Web3.providers.WebsocketProvider('ws://localhost:9545'))

contract('Swarm Example Tests', accounts => {

  const gasAmt = 3e6
  let loggedSwarmContent
  const address = accounts[0]

  beforeEach(async () => (
    {contract} = await swarm.deployed(), 
    {methods, events} = new web3.eth.Contract(contract._jsonInterface, contract._address) 
  ))

  it('Should have logged a new Oraclize query', async () => {
    const {returnValues:{description}} = await waitForEvent(events.LogNewOraclizeQuery) 
    assert.equal(description, 'Oraclize query was sent, standing by for the answer...', 'Oraclize query incorrectly logged!')
  })

  it('Callback should have logged a new Swarm content event', async () => {
    const {event} = await waitForEvent(events.LogNewSwarmContent)
    assert.equal(event, 'LogNewSwarmContent', 'Wrong event emitted for Swarm content!')
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
