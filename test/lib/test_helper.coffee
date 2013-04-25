global.path = require 'path'
global.os = require 'os'

global.chai = require 'chai'
global.assert = chai.assert

chai.should()

global.config = require 'nconf'
global.cli = require '../../src/cli'

config.overrides
  'redis_prefix': '_test_auth_service'
