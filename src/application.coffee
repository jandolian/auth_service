logger = require './logger'
cli = require './cli'
config = require 'nconf'
WebServer = require './webserver'
{identity} = require './identity'

###
The base application class.
###
class Application
  constructor: () ->
    @ws = new WebServer()

  abort: (str) =>
    logger.info('aborting...')
    process.exit(1)

module.exports = Application
