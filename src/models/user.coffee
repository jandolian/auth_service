_ = require 'underscore'
{generate_keypair} = require '../identity'

redis = require 'redis'
client = redis.createClient()

class User
  constructor: (@username) ->

  ###
  The user key prefix.

  @param {Array} args The list of keys to append
  @return {String} The redis-prefixed key
  ###
  @key: (params...) ->
    prefix = "demon_killer_users"
    params.unshift(prefix)
    if params.length > 1
      params.join(':')
    else
      params[0]

  @list: (cb) ->
    client.smembers User.key(), (err, members) ->
      cb(err, members)

  create: (cb) =>
    client.sismember User.key(), @username, (err, is_member) ->
      is_member = is_member > 0
      cb(err, is_member)

      # _.extend({ name: req.params['name'] }, generate_keypair())

module.exports = User
