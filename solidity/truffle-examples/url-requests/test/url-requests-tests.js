const Web3 = require('web3')
const {waitForEvent} = require('./utils')
const urlRequests = artifacts.require('./UrlRequests.sol')
const web3 = new Web3(new Web3.providers.WebsocketProvider('ws://localhost:9545'))

contract('Oraclize Example using Truffle', async accounts => {
  
  describe("URL Requests Tests", async () => {
    
    const gasAmt  = 3e6
    const addr = accounts[0]
    const urlReq = new Array(5).fill()

    it('Should log a new query upon a request for custom headers', async () => {
      const {contract} = await urlRequests.new()
      const {methods, events} = new web3.eth.Contract(contract._jsonInterface, contract._address)
      urlReq[0] = {methods,events}
      const {events:{newOraclizeQuery:{returnValues:{description}}}} = await methods.requestCustomHeaders().send({from: addr, gas: gasAmt})
      assert.equal(description, 'Oraclize query was sent, standing by for the answer...', 'Oraclize query incorrectly logged!')
    })

    it('Should log a new query upon a basic auth request', async () => {
      const {contract} = await urlRequests.new()
      const {methods, events} = new web3.eth.Contract(contract._jsonInterface, contract._address)
      urlReq[1] = {methods,events}
      const {events:{newOraclizeQuery:{returnValues:{description}}}} = await methods.requestBasicAuth().send({from: addr, gas: gasAmt})
      assert.equal(description, 'Oraclize query was sent, standing by for the answer...', 'Oraclize query incorrectly logged!')
    })

    it('Should log a new query upon a POST request', async () => {
      const {contract} = await urlRequests.new()
      const {methods, events} = new web3.eth.Contract(contract._jsonInterface, contract._address)
      urlReq[2] = {methods,events}
      const {events:{newOraclizeQuery:{returnValues:{description}}}} = await methods.requestPost().send({from: addr, gas: gasAmt})
      assert.equal(description, 'Oraclize query was sent, standing by for the answer...', 'Oraclize query incorrectly logged!')
    })

    it('Should log a new query upon a PUT request', async () => {
      const {contract} = await urlRequests.new()
      const {methods, events} = new web3.eth.Contract(contract._jsonInterface, contract._address)
      urlReq[3] = {methods,events}
      const {events:{newOraclizeQuery:{returnValues:{description}}}} = await methods.requestPut().send({from: addr, gas: gasAmt})
      assert.equal(description, 'Oraclize query was sent, standing by for the answer...', 'Oraclize query incorrectly logged!')
    })

    it('Should log a new query upon a for request cookies', async () => {
      const {contract} = await urlRequests.new()
      const {methods, events} = new web3.eth.Contract(contract._jsonInterface, contract._address)
      urlReq[4] = {methods,events}
      const {events:{newOraclizeQuery:{returnValues:{description}}}} = await methods.requestCookies().send({from: addr, gas: gasAmt})
      assert.equal(description, 'Oraclize query was sent, standing by for the answer...', 'Oraclize query incorrectly logged!')
    })

    it('Should log a failed second request for custom headers due to lack of funds', async () => {
      const {events:{newOraclizeQuery:{returnValues:{description}}}} = await urlReq[0].methods.requestCustomHeaders().send({from: addr, gas: gasAmt})
      assert.equal(description, 'Oraclize query was NOT sent, please add some ETH to cover for the query fee', 'Oraclize query incorrectly logged!')
    })

    it('Should log a failed second basic auth request due to lack of funds', async () => {
      const {events:{newOraclizeQuery:{returnValues:{description}}}} = await urlReq[1].methods.requestBasicAuth().send({from: addr, gas: gasAmt})
      assert.equal(description, 'Oraclize query was NOT sent, please add some ETH to cover for the query fee', 'Oraclize query incorrectly logged!')
    })

    it('Should log a failed second POST request due to lack of funds', async () => {
      const {events:{newOraclizeQuery:{returnValues:{description}}}} = await urlReq[2].methods.requestPost().send({from: addr, gas: gasAmt})
      assert.equal(description, 'Oraclize query was NOT sent, please add some ETH to cover for the query fee', 'Oraclize query incorrectly logged!')
    })

    it('Should log a failed second PUT request due to lack of funds', async () => {
      const {events:{newOraclizeQuery:{returnValues:{description}}}} = await urlReq[3].methods.requestPut().send({from: addr, gas: gasAmt})
      assert.equal(description, 'Oraclize query was NOT sent, please add some ETH to cover for the query fee', 'Oraclize query incorrectly logged!')
    })

    it('Should log a failed second request for cookies due to lack of funds', async () => {
      const {events:{newOraclizeQuery:{returnValues:{description}}}} = await urlReq[4].methods.requestCookies().send({from: addr, gas: gasAmt})
      assert.equal(description, 'Oraclize query was NOT sent, please add some ETH to cover for the query fee', 'Oraclize query incorrectly logged!')
    })

    it('Should emit result from request for custom headers', async () => {
      const {returnValues:{result}} = await waitForEvent(urlReq[0].events.LogResult)
      const expRes = '{"Accept-Encoding": "gzip, deflate", "Host": "httpbin.org", "Accept": "*/*", "User-Agent": "python-requests/2.19.1", "Connection": "close", "Content-Type": "json"}'
      assert.equal(expRes.slice(0, 50), result.slice(0, 50), 'Incorrect result from custom header request!')
    })

    it('Should emit result from basic auth request', async () => {
      const {returnValues:{result}} = await waitForEvent(urlReq[1].events.LogResult)
      const expRes = '{  \"authenticated\": true,   \"user\": \"myuser\"}'
      assert.equal(expRes, result, 'Incorrect result from basic auth request!')
    })

    it('Should emit result from POST request', async () => {
      const {returnValues:{result}} = await waitForEvent(urlReq[2].events.LogResult)
      const expRes = {
        "status": 200,
        "result": [{
          "query": "OX49 5NU",
          "result": {
            "postcode": "OX49 5NU",
            "quality": 1,
            "eastings": 464447,
            "northings": 195647,
            "country": "England",
            "nhs_ha": "South Central",
            "longitude": -1.069752,
            "latitude": 51.655929,
            "european_electoral_region": "South East",
            "primary_care_trust": "Oxfordshire",
            "region": "South East",
            "lsoa": "South Oxfordshire 011B",
            "msoa": "South Oxfordshire 011",
            "incode": "5NU",
            "outcode": "OX49",
            "parliamentary_constituency": "Henley",
            "admin_district": "South Oxfordshire",
            "parish": "Brightwell Baldwin",
            "admin_county": "Oxfordshire",
            "admin_ward": "Chalgrove",
            "ccg": "NHS Oxfordshire",
            "nuts": "Oxfordshire",
            "codes": {
              "admin_district": "E07000179",
              "admin_county": "E10000025",
              "admin_ward": "E05009735",
              "parish": "E04008109",
              "parliamentary_constituency": "E14000742",
              "ccg": "E38000136",
              "nuts": "UKJ14"
            }
          }
        }]
      }
      assert.equal(JSON.stringify(expRes).slice(0,85), result.slice(0,85), 'Incorrect result from POST request!') // Note: The long. & lat. can change hence the slice!
    })

    it('Should emit result from PUT request', async () => {
      const {returnValues:{result}} = await waitForEvent(urlReq[3].events.LogResult)
      const expRes = {
            "args": {},
            "data": "{\"testing\": \"it works\"}",
            "files": {},
            "form": {},
            "headers": {
              "Accept": "*/*",
              "Accept-Encoding": "gzip, deflate",
              "Connection": "close",
              "Content-Length": "23",
              "Content-Type": "application/json",
              "Host": "httpbin.org",
              "User-Agent": "python-requests/2.19.1"
            },
            "json": {
              "testing": "it works"
            },
            "method": "PUT",
            "origin": "n/a",
            "url": "http://httpbin.org/anything"
          }
      const expResSerialized = JSON.stringify(expRes)
      const resDeserialized = JSON.parse(result)
      const resSerialized = JSON.stringify(resDeserialized) // Sigh. Look what we have to resort to!
      assert.equal(expResSerialized.slice(0,50), resSerialized.slice(0,50), 'Incorrect result from PUT request!')
    })

    it('Should emit result from cookie request', async () => {
      const {returnValues:{result}} = await waitForEvent(urlReq[4].events.LogResult)
      const expRes = `{  "cookies": {    "thiscookie": "should be saved and visible :)"  }}`
      assert.equal(expRes, result, 'Incorrect result from cookie request!')
    })
  })
})
