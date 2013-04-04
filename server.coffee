credentials = require './credentials.json'

short = require 'short'
short.connect process.env.MONGOHQ_URL or 'mongodb://localhost/short'

restify = require 'restify'

port = process.env.PORT or 80

server = restify.createServer name: 'deadc'
server.use restify.bodyParser()
server.use restify.fullResponse() # set CORS, eTag, other common headers

# serve static site
server.get /index.html|style.css|app.js|favicon.ico/, restify.serveStatic directory: './static'

# email person a url
server.post '/send', (req, res, next) ->
  short.generate req.params.url, length: 7, (error, shortURL) ->
    res.send error or "#{server.address().address}:#{port}/#{shortURL.hash}"

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
  console.log "#{server.name} listening at #{server.url}"