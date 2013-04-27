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

  ###
  The list of users.
  
  @param {Function} cb The callback function
  ###
  @list: (cb) ->
    client.smembers User.key(), (err, members) ->
      cb(err, members)
  
  ###
  Finds an individual user.
  
  @param {String} username The username to search for
  @param {Function} cb The callback function
  ###
  @find: (username, cb) ->
    client.hgetall User.key(username), (err, userinfo) ->
      cb(err, userinfo)
  ###
  Creates a new user and adds them to the set of users.
  
  @param {String} email The users email address
  @param {String} password The users password
  @param {Function} cb The callback function
  ###
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
  
  ###
  Deletes a user and their information.
  
  @param {Function} cb The callback function
  ###
  delete: (cb) =>
    client.del User.key(@username), (err, success) =>
      client.srem User.key(), @username, (err, success) ->
        cb(err, success)

module.exports = User
