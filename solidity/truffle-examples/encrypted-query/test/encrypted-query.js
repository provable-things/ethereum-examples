const Web3 = require('web3')
const { waitForEvent } = require('./utils')
const encrypted = artifacts.require('./EncryptedQuery.sol')
const web3 = new Web3(new Web3.providers.WebsocketProvider('ws://localhost:9545'))

contract('Encrypted Query Tests', accounts => {

  let requestStatus
  const gasAmt = 3e6
  const address = accounts[0]

  beforeEach(async () => (
    { contract } = await encrypted.deployed(),
    { methods, events } = new web3.eth.Contract(
      contract._jsonInterface,
      contract._address
    )
  ))

  it('Should log a new Provable query', async () => {
    const {
      returnValues: {
        description
      }
    } = await waitForEvent(events.LogNewProvableQuery)
    assert.strictEqual(
      description,
      'Provable query was sent, standing by for the answer...',
      'Provable query incorrectly logged!'
    )
  })

  it('Callback should log a new request status', async () => {
    const {
      returnValues: {
        status
      }
    } = await waitForEvent(events.LogNewRequestStatus)
    requestStatus = status
    assert.isAbove(
      parseFloat(status),
      0,
      'A price should have been retrieved from Provable call!'
    )
  })

  it('Should set request status correctly in contract', async () => {
    const queriedStatus = await methods
      .requestStatus()
      .call()
    assert.strictEqual(
      requestStatus,
      queriedStatus,
      'Contract\'s status not set correctly!'
    )
  })

  it('Should log a failed query due to lack of funds', async () => {
    const { events } = await methods
      .update()
      .send({
        from: address,
        gas: gasAmt
      })
    const description = events.LogNewProvableQuery.returnValues.description
    assert.strictEqual(
      description,
      'Provable query was NOT sent, please add some ETH to cover for the query fee!',
      'Provable query incorrectly logged!'
    )
  })
})
