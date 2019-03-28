const fs = require('fs')
const path = require('path')
const API_PATH = path.resolve(__dirname, '../apikeys.js')

const PREFIX = 'Returned error: VM Exception while processing transaction: '

const waitForEvent = (_event, _from = 0, _to = 'latest') =>
  new Promise ((resolve, reject) =>
    _event({ fromBlock: _from, toBlock: _to }, (e, ev) =>
      e ? reject(e) : resolve(ev)))

const fileExists = _path => fs.existsSync(_path)

const getExternalVariable = _variable =>
  fileExists(API_PATH)
    ? require(API_PATH)[_variable]
    : process.env[_variable]
    ? process.env[_variable]
    : (console.log(`Cannot test! Please provide '${_variable}' as an environment variable, or export it from '${API_PATH}'!`), process.exit(1))

module.exports = {
  waitForEvent,
  PREFIX,
  getExternalVariable,
  fileExists
}
