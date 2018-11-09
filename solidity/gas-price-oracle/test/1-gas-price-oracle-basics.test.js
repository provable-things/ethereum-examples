const Web3 = require('web3')
const web3 = new Web3(new Web3.providers.WebsocketProvider('ws://localhost:9545'))
const gasPriceOracle = artifacts.require('GasPriceOracle.sol')
const { PREFIX, waitForEvent, increaseEVMTime, mineXBlocks} = require('./utils')
const {toBN, BN} = web3.utils

contract('Gas Price Oracle - Basic Tests', accounts => {

  let lBefore, sBefore, fBefore, hashBefore, time, hashAfter, lAfter, sAfter, fAfter, qID, conversionFactor, qPrice, blockNum = 0
  const gasAmt = 250000
  const startingPrice = 1234 * 1e8
  const mine50Blocks  = () => mineXBlocks(web3, 50)
  const increase3Mins = () => increaseEVMTime(web3, 60 * 3)
  const timestampDelta = new BN ((Date.now() / 1000 | 0) - 90)
  const fastForwardEVM = async () => {await mine50Blocks(), await increase3Mins()}

  beforeEach(async () => (
    {contract} = await gasPriceOracle.deployed(), 
    {methods, events} = new web3.eth.Contract(contract._jsonInterface, contract._address) // overwrite to get websockets & event subscriptions
  ))

  it(`Current safe low gas price should be starting price`, async () => {
    lBefore = await methods.getSafeLowPrice().call()
    assert.equal(lBefore, startingPrice, 'Safe low gas price not initialized correctly!')
  })

  it(`Current standard gas price should be starting price`, async () => {
    sBefore = await methods.getStandardPrice().call()
    assert.equal(sBefore, startingPrice, 'Standard gas price not initialized correctly!')
  })

  it(`Current fast gas price should be starting price`, async () => {
    fBefore = await methods.getFastPrice().call() 
    assert.equal(fBefore, startingPrice, 'Fast gas price not initialized correctly!')
  })

  it(`Time last updated should be 1`, async () => {
    const time = await methods.getLastUpdated().call()
    assert.equal(time, 1, `Last updated should be initialised to 1!`)
  })
  
  it(`Should have set off a recursive query upon contract creation`, async () => {
    hashBefore = await methods.nextRecursiveQuery().call()
    const {
      blockNumber,
      returnValues: {
        safeLowPrice,
        standardPrice,
        fastPrice,
        queryID,
        IPFSMultihash
      }
    } = await waitForEvent(events.LogGasPricesUpdated)
    const timestamp  = await methods.getLastUpdated().call()
    const lAfterCont = await methods.getSafeLowPrice().call()
    const sAfterCont = await methods.getStandardPrice().call()
    const fAfterCont = await methods.getFastPrice().call()
    conversionFactor = await methods.conversionFactor().call()
    blockNum         = blockNumber
    time             = timestamp
    qID              = queryID
    lAfter           = lAfterCont
    sAfter           = sAfterCont
    fAfter           = fAfterCont
    assert.equal(safeLowPrice * conversionFactor, lAfterCont, `Safe low price not logged in event correctly!`)
    assert.equal(standardPrice * conversionFactor, sAfterCont, `Safe low price not logged in event correctly!`)
    assert.equal(fastPrice * conversionFactor, fAfterCont, `Safe low price not logged in event correctly!`)
  })

  it(`Should have a balance left in the contract`, async () => {
    const balance = await web3.eth.getBalance(contract._address)
    assert.isTrue(toBN(balance).gt(new BN(0)), 'No ETH left in contract!')
  })

  it(`Should retrieve all three prices and time in one call`, async () => {
    const prices = await methods.getGasPrices().call()
    assert.equal(prices[0], lAfter, 'Safe low gas price not returning correctly from tuple!')
    assert.equal(prices[1], sAfter, 'Standard gas price not returning correctly from tuple!')
    assert.equal(prices[2], fAfter, 'Fast gas price not returning correctly from tuple!')
    assert.isTrue(toBN(prices[3]).gte(timestampDelta), 'Time updated not returning correctly from tuple!')
  })
  
  it(`Should return the time the gas prices were last updated`, async () => {
    const timestamp = await methods.getLastUpdated().call()
    assert.isFalse(toBN(timestamp).eq(new BN (0)), 'Timestamp is zero!')
    assert.isTrue(toBN(timestamp).gte(timestampDelta), 'Time updated not returning correctly from tuple!')
  })

  it(`Should have updated the low gas price in the struct`, async () => {
    const lAfterCont = await methods.getSafeLowPrice().call()
    assert.notEqual(lBefore, lAfter, 'Low gas price has not been set!') 
    assert.isFalse(toBN(lAfterCont).eq(new BN (0)), 'Low gas price should not be zero in struct!')
    assert.equal(lAfterCont, lAfter,`Low gas price didn't update properly in struct!`)
  })
    
  it(`Should have updated the standard gas price in the struct`, async () => {
    const sAfterCont = await methods.getStandardPrice().call()
    assert.notEqual(sBefore, sAfter, 'Standard gas price has not been set!') 
    assert.isTrue(toBN(sAfterCont).gt(new BN (0)), 'Standard gas price should not be zero in struct!')
    assert.equal(sAfterCont, sAfter,`Standard gas price didn't update properly in struct!`)
  })

  it(`Should have updated the fast gas price in the struct`, async () => {
    const fAfterCont = await methods.getFastPrice().call()
    assert.notEqual(fBefore, fAfter, 'Fast gas price has not been set!')
    assert.isTrue(toBN(fAfterCont).gt(new BN (0)), 'Fast gas price should not be zero in struct!')
    assert.equal(fAfterCont, fAfter,`Fast gas price didn't update properly in struct!`)
  })

  it(`Should have updated the time updated in the struct`, async () => {
    assert.isFalse(toBN(time).eq(new BN (1)), `Last updated time didn't update properly in struct!`)
    assert.isTrue(toBN(time).gt(new BN (0)), `Time should not be zero in struct!`)
  })

  it(`Recursive query should not be stale`, async () => {
    const recStale = await methods.isRecursiveStale().call()
    assert.isFalse(recStale, 'Recursive queries should not be stale!')
  })

  it(`Should return the delay to the next interval correctly`, async () => {
    const delay         = await methods.getDelayToNextInterval().call()
    const interval      = await methods.interval().call()
    const nowUTC        = Math.floor(Date.now() / 1000)
    const secs          = Math.floor(nowUTC % 60)
    const mins          = Math.floor((nowUTC / 60) % 60)
    const hour          = Math.floor((nowUTC / 60 / 60) % 24)
    const secsElapsed   = ((hour * 60 * 60) + (mins * 60) + secs)
    const secsInPeriod  = (((Math.floor(hour / interval)) + 1) * interval) * 60 * 60
    const expectedDelay = secsInPeriod - secsElapsed
    const calcDelay     = expectedDelay > 600 ? new BN(`${expectedDelay}`) : new BN(`${expectedDelay + (interval * 60 * 60)}`)
    const delta         = calcDelay.mul(new BN(`${0.01}`))
    assert.isTrue(toBN(delay).lte(calcDelay.add(delta)), `Interval time not set correctly in struct!`)
    assert.isTrue(toBN(delay).gte(calcDelay.sub(delta)), `Interval time not set correctly in struct!`)
  })

  it(`Should have sent a second recursive query`, async () => {
    hashAfter = await methods.nextRecursiveQuery().call()
    assert.notEqual(hashBefore, hashAfter, 'A second recursive query has not been made!')
  })

  it(`Should return a query price when supplying a gas limit`, async () => {
    const gasLimit = 2e5
    qPrice = await methods.getQueryPrice(gasLimit).call()
    // TODO: Calculate here to check!
    assert.isTrue(toBN(qPrice).gt(new BN(0)), `Query price isn't returning correctly!`)
  })

  it(`Should return a query price when supplying a gas price & limit`, async () => {
    const gasLimit  = 2e5
    const gasPrice  = 6e10
    const qPriceNow = await methods.getQueryPrice(gasLimit, gasPrice).call()
    // TODO: Calculate here to check!
    assert.isTrue(toBN(qPrice).gt(new BN (0)), `Query price isn't returning correctly!`)
    assert.notEqual(qPrice, qPriceNow, 'QUery price getter is not returning correctly!')
  })

  it(`Should allow a manual query with no params if correct price is supplied`, async () => {
    await fastForwardEVM()
    blockNum = await web3.eth.getBlockNumber()
    const gasLimit = await methods.gasLimit().call()
    const cost     = await methods.getQueryPrice(gasLimit).call()
    const account  = accounts[5]
    await methods.updateGasPrices().send({from: account, value: cost, gas: gasAmt})
    const {blockNumber} = await waitForEvent(events.LogGasPricesUpdated, blockNum)
    time = await methods.getLastUpdated()
  })

  it(`Should refund excess ETH when querying with no params`, async () => {
    await fastForwardEVM()
    blockNum = await web3.eth.getBlockNumber()
    const account   = accounts[5]
    const gasPrice    = new BN(`${20e9}`)
    const balBefore = await web3.eth.getBalance(account)
    const gasLimit  = await methods.gasLimit().call()
    const cost      = await methods.getQueryPrice(gasLimit).call()
    const amount    = new BN(cost).add(new BN(`${1e18}`))
    const {gasUsed} = await methods.updateGasPrices().send({from: account, value: amount, gas: gasAmt, gasPrice: gasPrice})
    const {returnValues: {safeLowPrice,standardPrice,fastPrice}} = await waitForEvent(events.LogGasPricesUpdated, blockNum )
    assert.notEqual(parseInt(safeLowPrice), 0, 'Safe low gas price not logged correctly!')
    assert.notEqual(parseInt(standardPrice), 0, 'Standard gas price not logged correctly!')
    assert.notEqual(parseInt(fastPrice), 0, 'Fast gas price not logged correctly!')
    const balAfter = await web3.eth.getBalance(account)
    const diff     = toBN(balBefore).sub(toBN(balAfter))
    const price    = new BN(`${cost}`).add(gasPrice.mul(new BN (`${gasUsed}`)))
    assert.isTrue(price.sub(diff).eq(new BN(`${0}`)), `Excess ETH wasn't refunded correctly!`)
  })

  it(`Should have updated the time the gas prices were last updated`, async () => {
    const timestamp = await methods.getLastUpdated().call()
    assert.isFalse(new BN(`${time}`).eq(new BN(`${timestamp}`)), `Time in gas struct was not updated after manual query with no params!`)
    time = timestamp
  })

  it(`Manual query with no params should not have updated the recursive query hash`, async () => {
    const hash = await methods.nextRecursiveQuery().call()
    assert.equal(hash, hashAfter, 'Next recursive query hash should not have been updated!')
  })

  it(`Should not allow a manual query with no params if ETH provided is < cost`, async () => {
    const expErr   = 'revert'
    const account  = accounts[5]
    const gasLimit = await methods.gasLimit().call()
    const cost     = await methods.getQueryPrice(gasLimit).call()
    const amount   = new BN(`${cost}`).sub(new BN(`${1e9}`))
    try {
      await methods.updateGasPrices().send({from: account, value: amount, gas: gasAmt})
      assert.fail(`Transaction should not have succeeded!`)
    } catch (e) {
      assert.isTrue(e.message.startsWith(`${PREFIX}${expErr}`), `Expected ${PREFIX + expErr} but got ${e.message} instead!`)
    }
  })

  it(`Should allow a manual query with a provided delay if supplied ETH = cost`, async () => {
    await fastForwardEVM()
    blockNum = await web3.eth.getBlockNumber()
    const delay    = 1
    const account  = accounts[5]
    const gasLimit = await methods.gasLimit().call()
    const cost     = await methods.getQueryPrice(gasLimit).call()
    await methods.updateGasPrices(delay).send({from: account, value: cost, gas: gasAmt})
    await waitForEvent(events.LogGasPricesUpdated, blockNum)
  })

  it(`Manual query with delay should not have updated the recursive query hash`, async () => {
    const hash = await methods.nextRecursiveQuery().call()
    assert.equal(hash, hashAfter, 'Next recursive query hash should not have been updated!')
  })

  it(`Should have updated the time the gas prices were last updated again`, async () => {
    const timestamp = await methods.getLastUpdated().call()
    assert.isFalse(new BN(`${time}`).eq(new BN(`${timestamp}`)), `Time in gas struct was not updated after manual query with no params!`)
    time = timestamp
  })

  it(`Should refund excess ETH when querying with "delay" param`, async () => {
    await fastForwardEVM()
    blockNum = await web3.eth.getBlockNumber()
    const delay     = 30
    const account   = accounts[5]
    const gasPrice    = new BN(`${20e9}`)
    const balBefore = await web3.eth.getBalance(account)
    const gasLimit  = await methods.gasLimit().call()
    const cost      = await methods.getQueryPrice(gasLimit).call()
    const amount    = new BN(cost).add(new BN(`${1e18}`))
    const {gasUsed} = await methods.updateGasPrices(delay).send({from: account, value: amount, gas: gasAmt, gasPrice: gasPrice})
    const {returnValues: {safeLowPrice,standardPrice,fastPrice}} = await waitForEvent(events.LogGasPricesUpdated, blockNum)
    assert.notEqual(parseInt(safeLowPrice), 0, 'Safe low gas price not logged correctly!')
    assert.notEqual(parseInt(standardPrice), 0, 'Standard gas price not logged correctly!')
    assert.notEqual(parseInt(fastPrice), 0, 'Fast gas price not logged correctly!')
    const balAfter = await web3.eth.getBalance(account)
    const diff     = toBN(balBefore).sub(toBN(balAfter))
    const price    = new BN(`${cost}`).add(gasPrice.mul(new BN (`${gasUsed}`)))
    assert.isTrue(price.sub(diff).eq(new BN(`${0}`)), `Excess ETH wasn't refunded correctly!`)
  })

  it(`Should have updated the time the gas prices were last updated`, async () => {
    const timestamp = await methods.getLastUpdated().call()
    assert.isFalse(new BN(`${time}`).eq(new BN(`${timestamp}`)), `Time in gas struct was not updated after manual query with one param!`)
    time = timestamp
  })

  it(`Should not allow a manual query with a provided delay if ETH provided is < cost`, async () => {
    const delay    = 1
    const expErr   = `revert`
    const account  = accounts[5]
    const gasLimit = await methods.gasLimit().call()
    const cost     = await methods.getQueryPrice(gasLimit).call()
    const amount   = new BN(`${cost}`).sub(new BN(`${1e9}`))
    try {
      await methods.updateGasPrices(delay).send({from: account, value: amount, gas: gasAmt})
    } catch (e) {
      assert.isTrue(e.message.startsWith(`${PREFIX}${expErr}`), `Expected ${expErr} but got ${e.message} instead!`)
    }
  })

  it(`Should allow a manual query with a provided delay & custom gas price`, async () => {
    await fastForwardEVM()
    blockNum = await web3.eth.getBlockNumber()
    const delay    = 1
    const gasLimit = await methods.gasLimit().call()
    const gasPrice = new BN(`${40e9}`)
    const cost     = await methods.getQueryPrice(gasLimit, gasPrice).call()
    const account  = accounts[5]
    await methods.updateGasPrices(delay, gasPrice).send({from: account, value: cost, gas: gasAmt})
    await waitForEvent(events.LogGasPricesUpdated, blockNum)
  })

  it(`Manual query with delay & custom gas price should not have updated the recursive query hash`, async () => {
    const hash = await methods.nextRecursiveQuery().call()
    assert.equal(hash, hashAfter, 'Next recursive query hash should not have been updated!')
  })

  it(`Should have updated the time the gas prices were last updated yet again`, async () => {
    const timestamp = await methods.getLastUpdated().call()
    assert.isFalse(new BN(`${time}`).eq(new BN(`${timestamp}`)), `Time in gas struct was not updated after manual query with two params!`)
    time = timestamp
  })

  it(`Should refund excess ETH when querying with "delay" & "gasPrice" params`, async () => {
    await fastForwardEVM()
    blockNum = await web3.eth.getBlockNumber()
    const delay     = 1
    const account   = accounts[5]
    const gasPrice  = new BN(`${60e9}`)
    const balBefore = await web3.eth.getBalance(account)
    const gasLimit  = await methods.gasLimit().call()
    const cost      = await methods.getQueryPrice(gasLimit, gasPrice).call()
    const amount    = new BN(cost).add(new BN(`${1e18}`))
    const {gasUsed} = await methods.updateGasPrices(delay, gasPrice).send({from: account, value: amount, gas: gasAmt, gasPrice: gasPrice})
    const {returnValues: {safeLowPrice,standardPrice,fastPrice}} = await waitForEvent(events.LogGasPricesUpdated, blockNum )
    assert.notEqual(parseInt(safeLowPrice), 0, 'Safe low gas price not logged correctly!')
    assert.notEqual(parseInt(standardPrice), 0, 'Standard gas price not logged correctly!')
    assert.notEqual(parseInt(fastPrice), 0, 'Fast gas price not logged correctly!')
    const balAfter = await web3.eth.getBalance(account)
    const diff     = toBN(balBefore).sub(toBN(balAfter))
    const price    = new BN(`${cost}`).add(gasPrice.mul(new BN (`${gasUsed}`)))
    assert.isTrue(price.sub(diff).eq(new BN(`${0}`)), `Excess ETH wasn't refunded correctly!`)
  })

  it(`Should not allow a manual query with a provided delay & custom gas price if insufficient ETH provided`, async () => {
    const delay    = 60
    const expErr   = 'revert'
    const account  = accounts[5]
    const gasPrice = new BN(`${20e9}`)
    const gasLimit = await methods.gasLimit().call()
    const cost     = await methods.getQueryPrice(gasLimit, gasPrice).call()
    const amount   = new BN(`${cost}`).sub(new BN(`${1e9}`))
    try {
      await methods.updateGasPrices(delay, gasPrice).send({from: account, value: amount, gas: gasAmt})
      assert.fail(`Transaction should not have succeeded!`)
    } catch (e) {
      assert.isTrue(e.message.startsWith(`${PREFIX}${expErr}`), `Expected ${expErr} but got ${e.message} instead!`)
    }
  })
})
