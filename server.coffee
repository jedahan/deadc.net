credentials = require './credentials.json'

short = require 'short'
short.connect process.env.MONGOHQ_URL or 'mongodb://localhost/short'

restify = require 'restify'
postmark = require('postmark')(credentials.key)

port = process.env.PORT or 80
domain = 'http://localhost'

server = restify.createServer()
server.use restify.bodyParser()
server.use restify.fullResponse() # set CORS, eTag, other common headers

# serve static site
server.get /index.html|screen.css|app.js|favicon.ico/, restify.serveStatic directory: './static'

# email person a url
server.post '/send', (req, res, next) ->
  short.generate req.params.url, length: 7, (error, shortURL) ->
    if error
      console.error error
    else
      tinyURL = "#{domain}:#{port}/#{shortURL.hash}"
      postmark.send
        "From": "jonathan@jedahan.com",
        "To": req.params.email,
        "Subject": tinyURL
        "TextBody": "<a href=#{tinyURL}>#{tinyURL}</a>"
      , (error, success) ->
        console.error error if error?
        res.send 'sent!'

# unshorten a url
server.get "/:hash", (req, res, next) ->
  short.retrieve req.params.hash, visitor: req.connection.remoteAddress, (error, shortURLObject) ->
    if error
      console.error error
    else
      if shortURLObject
        res.writeHead 302, 'Location': shortURLObject.URL
        res.end()
      else
        res.send "URL not found!", 404
        res.end()

server.listen port, ->
  console.log "Server running on port #{port}"