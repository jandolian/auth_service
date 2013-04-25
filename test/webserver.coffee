rest = require 'request'
url = require 'url'

logger = require '../src/logger'
WebServer = require '../src/webserver'

describe 'WebServer', ->
  ws = null

  u = "http://127.0.0.1:#{config.get('port')}"
  client = rest

  beforeEach (done) ->
    logger.clear()
    ws = new WebServer(config.get('port'))
    done()

  afterEach (done) ->
    ws.srv.close()
    done()

  it "should show the version info", (done) ->
    client.get url.resolve(u, '/version'), json: true
    , (err, res, data) ->
      assert.ifError err
      data.name.should.equal "demon_killer_auth_service"
      assert.notEqual data.version, undefined
      done()
