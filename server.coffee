credentials = require './credentials.json'

short = require 'short'
short.connect 'mongodb://localhost/short'

restify = require 'restify'
mailgun = require 'mailgun'

mail = new Mailgun credentials.key

port = process.env.PORT or 8080
domain = 'http://localhost'

_shorten = (url) ->
  short.generate url, length: 7, (error, shortURL) ->
    if error
      console.error error
    else
      return "#{domain}:#{port}/#{shortURL.hash}"

server = restify.createServer()
server.use restify.queryParser()
server.use restify.fullResponse() # set CORS, eTag, other common headers

# serve static site
server.get /index.html|screen.css|app.js|favicon.ico/, restify.serveStatic directory: './static'

# email person a url
server.post '/send', (req, res, next) ->
  shortURL = _shorten req.params.url
  sendText 'link@operator.mailgun.net', req.params.email, shortURL, shortURL, (err) ->
    console.error err if err?
  
# unshorten a url
server.get "/:hash", (req, res, next) ->
  short.retrieve req.params.hash, visitor: req.connection.remoteAddress, (error, shortURLObject) ->
    if error
      console.error error
    else
      if shortURLObject
        res.redirect shortURLObject.URL, 302
      else
        res.send "URL not found!", 404
        res.end()

server.listen port, ->
  console.log "Server running on port #{port}"