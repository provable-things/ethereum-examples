const {
    waitForEvent,
    getInfuraKey
} = require('./utils')

const Web3 = require('web3')
const randomExample = artifacts.require('./RandomExample.sol')
const RINKEBY_WSS = `wss://rinkeby.infura.io/ws/v3/${getInfuraKey()}`
const web3Socket = new Web3(new Web3.providers.WebsocketProvider(RINKEBY_WSS))

contract('Random Example Tests', async accounts => {

  const gasAmt = 3e6
  const address = accounts[0]

  before(async () => (
    { contract } = await randomExample.deployed(),
    { methods } = contract,
    { events } = new web3Socket.eth.Contract(
      contract._jsonInterface,
      contract._address
    )
  ))

  it('Should have logged a new Oraclize query', async () => {
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

  it('Callback should have logged a new uint random number result event', async () => {
    const {
      returnValues : {
       randomNumber
      }
    } = await waitForEvent(events.newRandomNumber_uint)
    assert.isAbove(
      parseInt(randomNumber),
      0,
      'A random number should have been retrieved from Oraclize call!'
    )
  }).timeout(600000)

  it('Should revert on second query attempt due to lack of funds', async () => {
    const expErr = 'Transaction has been reverted'
    try {
      await methods
        .update()
        .send({
          from: address,
          gas: gasAmt
        })
      assert.fail('Update transaction should not have succeeded!')
    } catch (e) {
      assert.isTrue(
        e.message.startsWith(`${expErr}`),
        `Expected ${expErr} but got ${e.message} instead!`
      )
    }
  })
})
