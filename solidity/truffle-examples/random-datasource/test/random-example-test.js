const Web3 = require('web3')
const { PREFIX, waitForEvent, getInfuraKey } = require('./utils')
const randomExample = artifacts.require('./RandomExample.sol')
const RINKEBY_WSS = `wss://rinkeby.infura.io/ws/v3/${getInfuraKey()}`
const provider = new Web3.providers.WebsocketProvider(RINKEBY_WSS)
const web31 = new Web3(provider)


contract('Random Example Tests', async accounts => {

  const gasAmt = 3e6
  const address = accounts[0]
  
  before(async () => (
	{ contract } = await randomExample.deployed(),
	{ methods } = contract, 
	{ events } = new web31.eth.Contract(contract._jsonInterface, contract._address) 
  ))
 
  it('Callback should have logged a new Random Number uint event', async () => {
    console.log("address: ", address)
    const {returnValues} = await waitForEvent(events.newRandomNumber_uint)
    assert.isAbove(parseInt(returnValues['0']), 0,'A random number should have been retrieved from Oraclize call!')
  })

  it('Should revert on second query attempt due to lack of funds', async () => {
    const expErr = 'Transaction has been reverted'
    try {
      await methods.update().send({from: address, gas: gasAmt})
      assert.fail('Update transaction should not have succeeded!')
    } catch (e) {
      assert.isTrue(e.message.startsWith(`${expErr}`), `Expected ${expErr} but got ${e.message} instead!`)
    }
  })
})
