express = require 'express'
http = require 'http'
async = require 'async'
path = require 'path'

config = require 'nconf'
logger = require './logger'
{identity, generate_hex} = require './identity'

user = require './routes/user'
version = require './routes/version'

errorHandler = (err, req, res, next) ->
  res.status 500
  res.render 'error', error: err

###
The webserver class.
###
class WebServer
  constructor: ->
    @app = express()
    @app.use(express.methodOverride())
    @app.use(express.bodyParser())
    @app.use(express.favicon())
    @app.use(@app.router)

    @app.use(errorHandler)
    @setup_routing()
    @srv = http.createServer(@app)
    @srv.listen(config.get('port'))
    logger.info "Webserver is up at: http://0.0.0.0:#{config.get('port')}"

  # Sets up the webserver routing.
  setup_routing: =>
    @app.get '/', version.display
    @app.get '/version', version.display

    @app.get '/user/:name', user.create

module.exports = WebServer
