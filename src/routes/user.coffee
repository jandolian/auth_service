_ = require 'underscore'
{generate_keypair} = require '../identity'

# Returns the base name and version of the app.
exports.create = (req, res, next) ->
  res.json 200,
    _.extend({ name: req.params['name'] }, generate_keypair())
