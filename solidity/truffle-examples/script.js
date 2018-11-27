const fs = require('fs')
/*
 * Usage: 
 * cd to root of truffle examples dir
 * pnpm install
 * node script.js
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

const SOURCE_PREFIX = `../`
const CONTRACTS_PATH = `/contracts/`
const SOURCE_COMPUTATION_PREFIX = `../computation-datasource/`

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
  `./wolfram-alpha${CONTRACTS_PATH + WOLF}`,
  `./swarm${CONTRACTS_PATH + SWARM}`,
  `./diesel-price${CONTRACTS_PATH + DIESEL}`,
  `./kraken-price-ticker${CONTRACTS_PATH + KRAKEN}`,
  `./youtube-views${CONTRACTS_PATH + YOUTUBE}`,
  `./bitcoin-balance${CONTRACTS_PATH + BTC}`,
  `./streamr${CONTRACTS_PATH + TWEET}`,
  `./url-requests${CONTRACTS_PATH + URL}`,
  `./delegated-math${CONTRACTS_PATH + MATH}`
]

const copyFile = (src, dest) => 
    fs.copyFile(src, dest, err => 
      err 
        ? console.log(`Error copying ${src} to ${dest}!`) 
        : console.log(`Successfully copied ${src} to ${dest}!`))

SOURCE_PATHS.map((src,i) => copyFile(src, DESTINATION_PATHS[i]))
