const Web3 = require('web3')
const {waitForEvent} = require('./utils')
const urlRequests = artifacts.require('./UrlRequests.sol')
const web3 = new Web3(new Web3.providers.WebsocketProvider('ws://localhost:9545'))

contract('Oraclize Example using Truffle', async ([ ACCOUNT_ZERO, ...accounts ]) => {

  describe("URL Requests Tests", async () => {

    const GAS_AMOUNT = 3e6
    const URL_REQUEST_CONTRACTS = new Array(5).fill()
    const QUERY_SENT_STRING = 'Oraclize query was sent, standing by for the answer...'
    const QUERY_NOT_SENT_STRING = 'Oraclize query was NOT sent, please add some ETH to cover for the query fee'

    it('Should log a new query upon a request for custom headers', async () => {
      const { contract } = await urlRequests.new()
      const { methods, events } = new web3.eth.Contract(
        contract._jsonInterface,
        contract._address
      )
      URL_REQUEST_CONTRACTS[0] = { methods, events }
      const { events: txEvents } = await methods
        .requestCustomHeaders()
        .send({
          from: ACCOUNT_ZERO,
          gas: GAS_AMOUNT
        })
      const description = txEvents.LogNewOraclizeQuery.returnValues.description
      assert.strictEqual(
        description,
        QUERY_SENT_STRING,
      )
    })

    it('Should log a new query upon a basic auth request', async () => {
      const { contract } = await urlRequests.new()
      const { methods, events } = new web3.eth.Contract(
        contract._jsonInterface,
        contract._address
      )
      URL_REQUEST_CONTRACTS[1] = { methods, events }
      const { events: txEvents } = await methods
        .requestBasicAuth()
        .send({
          from: ACCOUNT_ZERO,
          gas: GAS_AMOUNT
        })
      const description = txEvents.LogNewOraclizeQuery.returnValues.description
      assert.strictEqual(
        description,
        QUERY_SENT_STRING,
      )
    })

    it('Should log a new query upon a POST request', async () => {
      const { contract } = await urlRequests.new()
      const { methods, events } = new web3.eth.Contract(
        contract._jsonInterface,
        contract._address
      )
      URL_REQUEST_CONTRACTS[2] = { methods, events }
      const { events: txEvents } = await methods
        .requestPost()
        .send({
          from: ACCOUNT_ZERO,
          gas: GAS_AMOUNT
        })
      const description = txEvents.LogNewOraclizeQuery.returnValues.description
      assert.strictEqual(
        description,
        QUERY_SENT_STRING,
      )
    })

    it('Should log a new query upon a PUT request', async () => {
      const { contract } = await urlRequests.new()
      const { methods, events } = new web3.eth.Contract(
        contract._jsonInterface,
        contract._address
      )
      URL_REQUEST_CONTRACTS[3] = { methods, events }
      const { events: txEvents } = await methods
        .requestPut()
        .send({
          from: ACCOUNT_ZERO,
          gas: GAS_AMOUNT
        })
      const description = txEvents.LogNewOraclizeQuery.returnValues.description
      assert.strictEqual(
      description,
        QUERY_SENT_STRING,
      )
    })

    it('Should log a new query upon a for request cookies', async () => {
      const { contract } = await urlRequests.new()
      const { methods, events } = new web3.eth.Contract(
        contract._jsonInterface,
        contract._address
      )
      URL_REQUEST_CONTRACTS[4] = { methods, events }
      const { events: txEvents } = await methods
        .requestCookies()
        .send({
          from: ACCOUNT_ZERO,
          gas: GAS_AMOUNT
        })
      const description = txEvents.LogNewOraclizeQuery.returnValues.description
      assert.strictEqual(
        description,
        QUERY_SENT_STRING,
      )
    })

    it('Should log a failed second request for custom headers due to lack of funds', async () => {
      const { events } = await URL_REQUEST_CONTRACTS[0]
        .methods
        .requestCustomHeaders()
        .send({
          from: ACCOUNT_ZERO,
          gas: GAS_AMOUNT
        })
      const description = events.LogNewOraclizeQuery.returnValues.description
      assert.strictEqual(
        description,
        QUERY_NOT_SENT_STRING
      )
    })

    it('Should log a failed second basic auth request due to lack of funds', async () => {
      const { events } = await URL_REQUEST_CONTRACTS[1]
        .methods
        .requestBasicAuth()
        .send({
          from: ACCOUNT_ZERO,
          gas: GAS_AMOUNT
        })
      const description = events.LogNewOraclizeQuery.returnValues.description
      assert.strictEqual(
        description,
        QUERY_NOT_SENT_STRING
      )
    })

    it('Should log a failed second POST request due to lack of funds', async () => {
      const { events }  = await URL_REQUEST_CONTRACTS[2]
        .methods
        .requestPost()
        .send({
          from: ACCOUNT_ZERO,
          gas: GAS_AMOUNT
        })
      const description = events.LogNewOraclizeQuery.returnValues.description
      assert.strictEqual(
        description,
        QUERY_NOT_SENT_STRING
      )
    })

    it('Should log a failed second PUT request due to lack of funds', async () => {
      const { events } = await URL_REQUEST_CONTRACTS[3]
        .methods
        .requestPut()
        .send({
          from: ACCOUNT_ZERO,
          gas: GAS_AMOUNT
        })
      const description = events.LogNewOraclizeQuery.returnValues.description
      assert.strictEqual(
        description,
        QUERY_NOT_SENT_STRING
      )
    })

    it('Should log a failed second request for cookies due to lack of funds', async () => {
      const { events } = await URL_REQUEST_CONTRACTS[4]
        .methods
        .requestCookies()
        .send({
          from: ACCOUNT_ZERO,
          gas: GAS_AMOUNT
        })
      const description = events.LogNewOraclizeQuery.returnValues.description
      assert.strictEqual(
        description,
        QUERY_NOT_SENT_STRING
      )
    })

    it('Should emit result from request for custom headers', async () => {
      const {
        returnValues: { result }
      } = await waitForEvent(URL_REQUEST_CONTRACTS[0].events.LogResult)
      assert.isTrue(
        result.includes('"Accept-Encoding": "gzip, deflate"') &&
        result.includes('"Content-Type": "json"')
      )
    })

    it('Should emit result from basic auth request', async () => {
      const {
        returnValues: { result }
      } = await waitForEvent(URL_REQUEST_CONTRACTS[1].events.LogResult)
      const expRes = '{  \"authenticated\": true,   \"user\": \"myuser\"}'
      assert.strictEqual(
        expRes,
        result
      )
    })

    it('Should emit result from POST request', async () => {
      const SUCCESS_STATUS_CODE = 200
      const QUERIED_COUNTRY = "England"
      const QUERIED_POSTCODE = "OX49 5NU"
      const {
        returnValues: { result }
      } = await waitForEvent(URL_REQUEST_CONTRACTS[2].events.LogResult)
      const jsonParsedResult = JSON.parse(result)
      assert.strictEqual(
        jsonParsedResult.status,
        SUCCESS_STATUS_CODE
      )
      assert.strictEqual(
        jsonParsedResult.result[0].result.country,
        QUERIED_COUNTRY
      )
      assert.strictEqual(
        jsonParsedResult.result[0].result.postcode,
        QUERIED_POSTCODE
      )
    })

    it('Should emit result from PUT request', async () => {
      const EXPECTED_METHOD = "PUT"
      const EXPECTED_KEY = "testing"
      const EXPECTED_VALUE = "it works"
      const EXPECTED_HEADERS = "gzip, deflate"
      const EXPECTED_DATA_STRING = `{"${EXPECTED_KEY}": "${EXPECTED_VALUE}"}`
      const {
        returnValues: { result }
      } = await waitForEvent(URL_REQUEST_CONTRACTS[3].events.LogResult)
      const jsonParsedResult = JSON.parse(result)
      assert.strictEqual(
        jsonParsedResult.method,
        EXPECTED_METHOD
      )
      assert.strictEqual(
        jsonParsedResult.data,
        EXPECTED_DATA_STRING
      )
      assert.strictEqual(
        jsonParsedResult.headers["Accept-Encoding"],
        EXPECTED_HEADERS
      )
      assert.strictEqual(
        jsonParsedResult.json[EXPECTED_KEY],
        EXPECTED_VALUE
      )
    })

    it('Should emit result from cookie request', async () => {
      const EXPECTED_COOKIE_KEY = "thiscookie"
      const EXPECTED_COOKIE_VALUE = "should be saved and visible :)"
      const {
        returnValues: { result }
      } = await waitForEvent(URL_REQUEST_CONTRACTS[4].events.LogResult)
      const jsonParsedResult = JSON.parse(result)
      assert.strictEqual(
        jsonParsedResult.cookies[EXPECTED_COOKIE_KEY],
        EXPECTED_COOKIE_VALUE
      )
    })
  })
})
