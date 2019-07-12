const {
  PREFIX,
  waitForEvent
} = require('./utils')

const Web3 = require('web3')
const wolframAlpha = artifacts.require('./WolframAlpha.sol')
const web3 = new Web3(new Web3.providers.WebsocketProvider('ws://localhost:9545'))

contract('WolframAlpha Example Tests', accounts => {

  const gasAmt = 3e6
  let loggedTemperature
  const address = accounts[0]

  beforeEach(async () => (
    { contract } = await wolframAlpha.deployed(),
    { methods, events } = new web3.eth.Contract(
      contract._jsonInterface,
      contract._address
    )
  ))

  it('Should have logged a new Provable query', async () => {
    const {
      returnValues: {
        description
      }
    } = await waitForEvent(events.LogNewProvableQuery)
    assert.strictEqual(
    description,
      'Provable query was sent, standing by for the answer...',
      'Provable query incorrectly logged!')
  })

  it('Callback should have logged a new temperature measure event', async () => {
    const {
      returnValues: {
        temperature
      }
    } = await waitForEvent(events.LogNewTemperatureMeasure)
    loggedTemperature = temperature
    assert.isAbove(
      parseInt(temperature),
      0,
      'A temperature should have been retrieved from Provable call!'
    )
  })

  it('Should have saved the new temperature', async () => {
    const temprCont = await methods
      .temperature()
      .call()
    assert.strictEqual(
      loggedTemperature,
      temprCont,
      'Contract\'s temperature price not set correctly!'
    )
  })

  it('Should revert on second query attempt due to lack of funds', async () => {
    const expErr = 'revert'
    try {
      await methods
        .update()
        .send({
          from: address,
          gas: gasAmt
        })
      assert.fail('Update transaction should not have succeeded!')
    } catch(e) {
      assert.isTrue(
        e.message.startsWith(`${PREFIX}${expErr}`),
        `Expected ${expErr} but got ${e.message} instead!`
      )
    }
  })
})
