global.WebSocket = require('ws')
var StreamrClient = require('streamr-client')

var optMinutes
console.log(process.argv)

if(!isNaN(parseInt(process.argv[2]))) {
  var parsed = parseInt(process.argv[2]);
  console.log('User-defined duration argument found... Setting duration to ' + parsed + ' minutes')
  optMinutes = parsed
} else {
  console.log('No appropriate duration defined by user, falling back to 1 minute...')
  optMinutes = 1
}

var client = new StreamrClient()
var ctr = 0
var start
var duration = optMinutes * 60 * 1000

var subscription = client.subscribe(
  'ln2g8OKHSdi7BcL-bcnh2g',
  function(message) {

    if (Date.now() > start + duration) {
      console.log(ctr)
      process.exit(0)
  	}

    ctr++
  }
)

// Event binding examples
client.bind('connected', function() {
	console.log('A connection has been established!')
})

subscription.bind('subscribed', function() {
	console.log('Subscribed to '+subscription.streamId)
  start = Date.now()
})
