const waitForEvent = (_event, _from = 0, _to = 'latest') => 
  new Promise ((resolve,reject) => 
    _event({fromBlock: _from, toBlock: _to}, (e, ev) => 
      e ? reject(e) : resolve(ev)))

const PREFIX = "Returned error: VM Exception while processing transaction: "

const increaseEVMTime = (web3, secsToIncreaseBy) => 
  new Promise((resolve, reject) => 
    web3.currentProvider.send({jsonrpc: '2.0', method: 'evm_increaseTime', params:[secsToIncreaseBy], id: Date.now()}, e => 
      e ? reject(e) : web3.currentProvider.send({jsonrpc: '2.0', method: 'evm_mine', params: [], id: Date.now() + 1}, (e2, res) => 
        e2 ? reject(e2) : resolve(res))))

const mineXBlocks = (web3, numBlocks) => 
  new Promise((resolve, reject) => 
    Promise.all(new Array (numBlocks).fill().map((_,i) => 
      new Promise ((res, rej) => 
        web3.currentProvider.send({jsonrpc: '2.0', method: 'evm_mine', params: [], id: Date.now() + i}, e =>
          e ? rej() : res())))).then(resolve).catch(reject))

const getTimestamp = blockNum => 
  new Promise ((resolve, reject) => 
    web3.eth.getBlock(blockNum, false, (e, b) => 
      e ? reject(e) : resolve(b.timestamp)))

module.exports = {
  increaseEVMTime,
  getTimestamp,
  waitForEvent,
  mineXBlocks,
  PREFIX
}