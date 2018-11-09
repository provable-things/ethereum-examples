const Web3 = require('web3')
const {waitForEvent} = require('./utils')
const delegatedMath = artifacts.require('DelegatedMath.sol')
const web3 = new Web3(new Web3.providers.WebsocketProvider('ws://localhost:9545'))

contract('Delegated Math Example Tests', () => {

  let delegateResult
  
  beforeEach(async () => (
    {contract} = await delegatedMath.deployed(), 
    {methods, events} = new web3.eth.Contract(contract._jsonInterface, contract._address) 
  ))

  it('Should retrieve a result from an offchain computation', async () => {
    const {returnValues:{result}} = await waitForEvent(events.LogOperationResult)
    delegateResult = result
    assert.isAbove(parseInt(result), 0, 'No result was retrieved from the offchain computation!')
  })

  it('Should have calculated the offchain computation correctly', async () => {
    const delegateOp = 32 + 125 // Note: Operands are taken from the smart-contract
    assert.equal(delegateOp, delegateResult, 'Offchain computation was not performed correctly!')
  })

})
