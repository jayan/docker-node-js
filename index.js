var express = require('express')
var app = express()
var port = process.env.PORT || 80

app.get('/', function (req, res) {
  res.send('Hello World!')
})

if (process.env.NODE_ENV === 'test') {
  module.exports = app
} else {
  app.listen(port)
}

