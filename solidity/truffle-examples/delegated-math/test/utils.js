const PREFIX = 'Returned error: VM Exception while processing transaction: '

const waitForEvent = (_event, _from = 0, _to = 'latest') => 
  new Promise ((resolve,reject) => 
    _event({fromBlock: _from, toBlock: _to}, (e, ev) => 
      e ? reject(e) : resolve(ev)))
      
module.exports = {
  waitForEvent,
  PREFIX
} 
