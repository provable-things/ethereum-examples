const Web3 = require('web3')
const web3 = new Web3(new Web3.providers.WebsocketProvider('ws://localhost:9545'))
const gasPriceOracle = artifacts.require('GasPriceOracle.sol')
const {waitForEvent, increaseEVMTime, mineXBlocks} = require('./utils')
const {BN} = web3.utils

contract('Gas Price Oracle Stale Tests', accounts => {

  let blockNum = 0
  const gasAmt = 250000

  const mine50Blocks  = () => mineXBlocks(web3, 50)
  const increase3Mins = () => increaseEVMTime(web3, 60 * 3)
  const fastForwardEVM = async () => {await mine50Blocks(), await increase3Mins()}

  beforeEach(async () => (
    {contract} = await gasPriceOracle.deployed(), 
    {methods, events} = new web3.eth.Contract(contract._jsonInterface, contract._address)
  ))

  it(`Should have set off a recursive query upon contract creation`, async () => {
    const hashBefore = await methods.nextRecursiveQuery().call()
    const hashAfter = await waitForEvent(events.LogGasPricesUpdated)
    assert.notEqual(hashBefore, hashAfter, `Initial query should have begun recursion!`)
  })

  it(`Should advance time until the recursive query becomes stale`, async () => {
    const week = 1 * 60 * 60 * 24 * 7
    await increaseEVMTime(web3, week)
    await mineXBlocks(web3, 100)
    const stale = await methods.isRecursiveStale().call()
    assert.isTrue(stale, 'Recursive queries should now be stale!')
  })

  it(`Queries using delay of 0, sufficient ETH but gas prices < than previous recursive queries should succeed but not restart recursion`, async () => {
    const delay        = 0
    const account      = accounts[5]
    const recIDBefore  = await methods.nextRecursiveQuery().call()
    const structBefore = await methods.queryIDs(recIDBefore).call()
    const priceToUse   = new BN(`${structBefore[4]}`).sub(new BN(`${1e9}`))
    const gasLimit     = await methods.gasLimitRec().call()
    assert.isTrue(priceToUse.gt(new BN (0)), 'Price to use should be above zero!')
    const cost = await methods.getQueryPrice(gasLimit, priceToUse).call()
    await methods.updateGasPrices(delay, priceToUse).send({from: account, value: cost, gas: gasAmt})
    await waitForEvent(events.LogGasPricesUpdated, blockNum)
    const stale       = await methods.isRecursiveStale().call()
    const recIDAfter  = await methods.nextRecursiveQuery().call()
    const structAfter = await methods.queryIDs(recIDAfter).call()
    assert.equal(recIDBefore, recIDAfter, 'Recursive ID should not have been updated!') 
    assert.equal(delay, 0, 'Delay should be 0 for this test!')
    assert.isFalse(structAfter[2], 'Query should not be a revival!')
    assert.isTrue(stale, 'Recursive queries should still be stale!')
  })

  it(`Queries using delay of 0, sufficient ETH but gas prices = to previous recursive queries should succeed but not restart recursion`, async () => {
    await fastForwardEVM()
    blockNum = await web3.eth.getBlockNumber()
    const delay        = 0
    const account      = accounts[5]
    const recIDBefore  = await methods.nextRecursiveQuery().call()
    const structBefore = await methods.queryIDs(recIDBefore).call()
    const priceToUse   = new BN(`${structBefore[4]}`)
    const gasLimit     = await methods.gasLimitRec().call()
    const cost         = await methods.getQueryPrice(gasLimit, priceToUse).call()
    await methods.updateGasPrices(delay, priceToUse).send({from: account, value: cost, gas: gasAmt})
    await waitForEvent(events.LogGasPricesUpdated, blockNum)
    const stale       = await methods.isRecursiveStale().call()
    const recIDAfter  = await methods.nextRecursiveQuery().call()
    const structAfter = await methods.queryIDs(recIDAfter).call()
    assert.equal(recIDBefore, recIDAfter, 'Recursive ID should not have been updated!')
    assert.equal(delay, 0, 'Delay should be 0 for this test!')
    assert.isFalse(structAfter[2], 'Query should not be a revival!')
    assert.isTrue(stale, 'Recursive queries should still be stale!')
  })

  it('Queries of delay > 0 & high gas prices should not successed but not restart recursion', async () => {
    await fastForwardEVM()
    blockNum = await web3.eth.getBlockNumber()
    const delay       = 1
    const account     = accounts[5]
    const gasPrice    = new BN(`${100e9}`)
    const recIDBefore = await methods.nextRecursiveQuery().call()
    const gasLimit    = await methods.gasLimitRec().call()
    const cost        = await methods.getQueryPrice(gasLimit, gasPrice).call()
    await methods.updateGasPrices(delay).send({from: account, value: cost, gas: gasAmt})
    await waitForEvent(events.LogGasPricesUpdated, blockNum)
    const stale       = await methods.isRecursiveStale().call()
    const recIDAfter  = await methods.nextRecursiveQuery().call()
    const structAfter = await methods.queryIDs(recIDAfter).call()
    assert.isAbove(delay, 0, 'Delay should be > 0 for this test!')
    assert.isTrue(stale, 'Recursive queries should still be stale!')
    assert.equal(recIDBefore, recIDAfter, 'Recursive ID should not have been updated!')
    assert.isFalse(structAfter[2], 'Query should not be a revival!')
  })

  it(`Queries with delay of 0, high gas prices, but insufficient ETH should not succeed nor restart recursion`, async () => {
    const delay       = 0
    const account     = accounts[5]
    const gasPrice    = new BN(`${100e9}`)
    const recIDBefore = await methods.nextRecursiveQuery().call()
    const gasLimit    = await methods.gasLimitRec().call()
    const cost        = await methods.getQueryPrice(gasLimit, gasPrice).call()
    const amount      = new BN(`${cost}`).sub(new BN(`${1e9}`))
    try {
      await methods.updateGasPrices(delay, gasPrice).send({from: account, value: amount, gas: gasAmt})
      assert.fail(`Transaction should not have succeeded!`)
    } catch (e) {
      const stale = await methods.isRecursiveStale().call()
      assert.equal(delay, 0, 'Delay should be 0 for this test!')
      assert.isTrue(stale, 'Recursive queries should still be stale!')
      const recIDAfter = await methods.nextRecursiveQuery().call()
      const qIDStruct  = await methods.queryIDs(recIDAfter).call()
      assert.equal(recIDBefore, recIDAfter, 'Recursive ID should not have been updated!')
      assert.isFalse(qIDStruct[2], 'Query should not be a revival!')
    }
  })
    
  it(`Query with delay of 0, a gas price 1Gwei higher than prior call, plus sufficient ETH supplied should succceed and restart recursion`, async () => {
    await fastForwardEVM()
    blockNum = await web3.eth.getBlockNumber()
    const staleBefore  = await methods.isRecursiveStale().call()
    assert.isTrue(staleBefore, 'Recursive queries should be stale!')
    const delay        = 0
    const account      = accounts[5]
    const recIDBefore  = await methods.nextRecursiveQuery().call()
    const structBefore = await methods.queryIDs(recIDBefore).call()
    const gasLimit     = await methods.gasLimitRec().call()
    const priceToUse   = new BN(`${structBefore[4]}`).add(new BN(`${1e9}`))
    const cost         = await methods.getQueryPrice(gasLimit, priceToUse).call()
    const amount       = new BN(`${cost}`).mul(new BN(`${10}`))
    await methods.updateGasPrices(delay, priceToUse).send({from: account, value: amount, gas: gasAmt})
    const interimID     = await methods.nextRecursiveQuery().call()
    const interimStruct = await methods.queryIDs(interimID).call()
    const staleInterim  = await methods.isRecursiveStale().call()
    assert.isTrue(interimStruct[2], 'Query should be a revival!')
    assert.isFalse(interimStruct[0], 'Despite manual, ∵ its restarting recursion, query should be an "automated" one!')
    assert.notEqual(recIDBefore, interimID, 'There should be a new recursive query ID!')
    assert.isTrue(staleInterim, ' Recursive queries should still be stale whilst recursive ID is a revival!')
    await waitForEvent(events.LogGasPricesUpdated, blockNum)
    const recIDAfter  = await methods.nextRecursiveQuery().call()
    const structAfter = await methods.queryIDs(recIDAfter).call()
    const staleAfter  = await methods.isRecursiveStale().call()
    assert.equal(delay, 0, 'Delay should be 0 for this test!')
    assert.notEqual(interimID, recIDAfter, 'There should be a new recursive query ID!')
    assert.isFalse(staleAfter, 'Recursive queries should no longer be stale!')
    assert.isFalse(structAfter[2], 'Final query should not be a be a revival!')
    assert.isFalse(structAfter[0], 'Final detected query should be an automated one!')
  })
})
