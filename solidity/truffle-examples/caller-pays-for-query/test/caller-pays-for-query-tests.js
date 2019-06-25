const {
  waitForEvent,
  shouldRevert
} = require('./utils')

const Web3 = require('web3')
const callerPaysForQueryContract = artifacts.require('CallerPaysForQuery.sol')
const web3WithWebSockets = new Web3(new Web3.providers.WebsocketProvider('ws://localhost:9545'))
const { toBN } = web3.utils

contract('❍ Provable Truffle Examples:', ([
  _deployer,
  _user,
  ...accounts
]) => {
  describe('❍ Caller-pays-for-query tests', () => {
    let contractEvents
    let contractMethods
    let contractAddress
    let contractQueryPrice
    let contractEthPriceInUSDString

    const gasPrice = 20e9
    const gasLimit = 4e6

    it('Should get contract methods & events', async () => {
      const { contract: deployedContract } = await callerPaysForQueryContract.deployed()
      const { methods, events } = new web3WithWebSockets.eth.Contract(
        deployedContract._jsonInterface,
        deployedContract._address
      )
      contractEvents = events
      contractMethods = methods
      contractAddress = deployedContract._address
    })

    it('Should be able to call `queryPrice` public getter', async () => {
      const queryPrice = await contractMethods
        .queryPrice()
        .call()
      contractQueryPrice = parseInt(queryPrice)
    })

    it('Contract balance should be 0', async () => {
      const contractBalance = await web3.eth.getBalance(contractAddress)
      assert.isTrue(parseInt(contractBalance) === 0)
    })

    it('Query price should be > 0', () => {
      assert.isTrue(contractQueryPrice > 0)
    })

    it('User cannot make query if msg.value === 0', async () => {
      await shouldRevert(
        contractMethods
          .getEthPriceInUSDViaProvable()
          .send({
            value: 0,
            from: _user,
            gas: gasLimit,
            gasPrice: gasPrice
          })
      )
    })

    it('User cannot make query if msg.value < query cost', async () => {
      await shouldRevert(
        contractMethods
          .getEthPriceInUSDViaProvable()
          .send({
            value: contractQueryPrice - 1,
            from: _user,
            gas: gasLimit,
            gasPrice: gasPrice
          })
      )
    })

    it('User can make query if msg.value === query cost', () => {
      contractMethods
        .getEthPriceInUSDViaProvable()
        .send({
          value: contractQueryPrice,
          from: _user,
          gas: gasLimit,
          gasPrice: gasPrice
        })
    })

    it('Query should have emitted event with ETH price in USD', async () => {
      const event = await waitForEvent(contractEvents.LogNewEthPrice)
      contractEthPriceInUSDString = event.returnValues._price
    })

    it('Eth price in USD should be saved in contract', async () => {
      const ethPriceInUSDString = await contractMethods
        .ethPriceInUSD()
        .call()
      assert.isTrue(parseInt(ethPriceInUSDString) > 0)
      assert.strictEqual(
        ethPriceInUSDString,
        contractEthPriceInUSDString
      )
    })

    it('User should get refund when making query but sending > query cost', async () => {
      const overspendAmount = contractQueryPrice * 2
      const balanceBeforeBN = toBN(await web3.eth.getBalance(_user))
      const { gasUsed } = await contractMethods
        .getEthPriceInUSDViaProvable()
        .send({
          from: _user,
          gas: gasLimit,
          gasPrice: gasPrice,
          value: overspendAmount
        })
      const balanceAfterBN = toBN(await web3.eth.getBalance(_user))
      const totalGasCostBN = toBN(gasUsed).mul(toBN(gasPrice))
      const balanceDeltaBN = balanceBeforeBN.sub(balanceAfterBN)
      const expectedDeltaBN = toBN(contractQueryPrice).add(totalGasCostBN)
      assert.isTrue(expectedDeltaBN.eq(balanceDeltaBN))
    })
  })
})
