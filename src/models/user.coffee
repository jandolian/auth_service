_ = require 'underscore'
{generate_keypair} = require '../identity'

bcrypt = require 'bcrypt'
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

  create: (email, password, cb) =>
    bcrypt.hash password, 10, (err, hash) =>
      client.hmset User.key(@username),
        "name", @username,
        "email", email,
        "password", hash,
        (err, updated) =>
          client.sadd User.key(), @username, (err, added) =>
            cb(err, updated)
      # _.extend({ name: req.params['name'] }, generate_keypair())

module.exports = User
