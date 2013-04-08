short = require 'short'
short.connect process.env.MONGOHQ_URL or 'mongodb://localhost/short'

restify = require 'restify'

port = process.env.PORT or 80

server = restify.createServer name: 'deadc'
server.use restify.bodyParser()
server.use restify.fullResponse() # set CORS, eTag, other common headers
server.use restify.gzipResponse() # use compression if available

# email person a url
server.post '/shorten', (req, res, next) ->
  short.generate req.params.url, length: 7, (error, shortURL) ->
    res.send error or shortURL.hash

# serve static site
server.get /^\/$|404.html|index.html|favicon.png|style.css|components\/reqwest\/reqwest.min.js/, restify.serveStatic directory: './public', default: 'index.html', maxAge: 60*60*24*7

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
        res.send new restify.NotFoundError "URL not found!"
        res.end()

server.listen port, ->
  console.log "#{server.name} listening at #{server.url}"