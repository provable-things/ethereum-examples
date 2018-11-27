const fs = require('fs')
/*
 * Usage: 
 * pnpm install in root of dir
 * node ./script.js
 */
const SWARM = 'Swarm.sol'
const URL = 'UrlRequests.sol'
const WOLF = 'WolframAlpha.sol'
const DIESEL = 'DieselPrice.sol'
const MATH = 'DelegatedMath.sol'
const YOUTUBE = 'YoutubeViews.sol'
const KRAKEN = 'KrakenPriceTicker.sol'
const BTC = 'BitcoinAddressExample.sol'
const TWEET = 'StreamrTweetsCounter.sol'

const SOURCE_PREFIX = `./solidity/`
const CONTRACTS_PATH = `/contracts/`
const DESTINATION_PREFIX = SOURCE_PREFIX + `truffle-examples/`
const SOURCE_COMPUTATION_PREFIX = SOURCE_PREFIX + `computation-datasource/`

const SOURCE_PATHS = [
  SOURCE_PREFIX + WOLF,
  SOURCE_PREFIX + SWARM,
  SOURCE_PREFIX + DIESEL,
  SOURCE_PREFIX + KRAKEN,
  SOURCE_PREFIX + YOUTUBE, 
  `${SOURCE_COMPUTATION_PREFIX}bitcoin/${BTC}`,
  `${SOURCE_COMPUTATION_PREFIX}streamr/${TWEET}`,
  `${SOURCE_COMPUTATION_PREFIX}url-requests/${URL}`,
  `${SOURCE_COMPUTATION_PREFIX}delegatedMath/${MATH}` // NOTE: Have changed path in v0.5 for consistency!
]

const DESTINATION_PATHS = [
  `${DESTINATION_PREFIX}wolfram-alpha${CONTRACTS_PATH + WOLF}`,
  `${DESTINATION_PREFIX}swarm${CONTRACTS_PATH + SWARM}`,
  `${DESTINATION_PREFIX}diesel-price${CONTRACTS_PATH + DIESEL}`,
  `${DESTINATION_PREFIX}kraken-price-ticker${CONTRACTS_PATH + KRAKEN}`,
  `${DESTINATION_PREFIX}youtube-views${CONTRACTS_PATH + YOUTUBE}`,
  `${DESTINATION_PREFIX}bitcoin-balance${CONTRACTS_PATH + BTC}`,
  `${DESTINATION_PREFIX}streamr${CONTRACTS_PATH + TWEET}`,
  `${DESTINATION_PREFIX}url-requests${CONTRACTS_PATH + URL}`,
  `${DESTINATION_PREFIX}delegated-math${CONTRACTS_PATH + MATH}`
]

const copyFile = (src, dest) => 
    fs.copyFile(src, dest, err => 
      err 
        ? console.log(`Error copying ${src} to ${dest}!`) 
        : console.log(`Successfully copied ${src} to ${dest}!`))

SOURCE_PATHS.map((src,i) => copyFile(src, DESTINATION_PATHS[i]))
