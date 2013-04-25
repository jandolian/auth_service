{generate_keypair} = require '../identity'

bcrypt = require 'bcrypt'
redis = require 'redis'
config = require 'nconf'
client = redis.createClient()

class User
  constructor: (@username) ->

  ###
  The user key prefix.

  @param {Array} args The list of keys to append
  @return {String} The redis-prefixed key
  ###
  @key: (params...) ->
    prefix = [config.get('redis_prefix'), "users"].join('_')
    params.unshift(prefix)
    if params.length > 1
      params.join(':')
    else
      params[0]

  @list: (cb) ->
    client.smembers User.key(), (err, members) ->
      cb(err, members)

  create: (email, password, cb) =>
    keypair = generate_keypair()
    bcrypt.hash password, 10, (err, hash) =>
      client.hmset User.key(@username),
        "name", @username,
        "email", email,
        "password", hash,
        "token", keypair.token,
        "secret", keypair.shared_secret,
        (err, updated) =>
          client.sadd User.key(), @username, (err, added) =>
            cb(err, updated)

module.exports = User
