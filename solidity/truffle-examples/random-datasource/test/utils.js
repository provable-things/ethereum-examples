const fs = require('fs')
const path = require('path')
const API_PATH = path.join(__dirname, '../', 'apikeys.js')

const PREFIX = 'Returned error: VM Exception while processing transaction: '

const waitForEvent = (_event, _from = 0, _to = 'latest') => 
  new Promise ((resolve,reject) => 
    _event({fromBlock: _from, toBlock: _to}, (e, ev) => 
      e ? reject(e) : resolve(ev)))

const fileExists = _path => fs.existsSync(_path)

const getInfuraKey = () => fileExists(API_PATH)
  ? require(API_PATH)['infuraKey']
  : process.env['infuraKey']
  ? process.env['infuraKey']
  : (console.log(`Cannot test! Please provide 'infuraKey' as an environment variable, or export it from '${API_PATH}'!`), process.exit(1))

module.exports = {
  waitForEvent,
  PREFIX,
  getInfuraKey
} 
