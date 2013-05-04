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
    client.smembers User.key(), cb
  
  ###
  Finds an individual user.
  
  @param {String} username The username to search for
  @param {Function} cb The callback function
  ###
  @find: (username, cb) ->
    client.hgetall User.key(username), cb
    
  ###
  Verifies whether or not a user exists.
  
  @param {String} username The username to verify
  @param {Function} cb The callback function
  ###
  @exists: (username, cb) ->
    client.sismember User.key(), username, (err, exists) ->
      cb(err, exists == 1)
    
  ###
  Deletes all users.
  
  @param {Function} cb The callback function
  ###
  @delete_all: (cb) ->
    client.keys "#{User.key()}*", (err, keys) ->
      for k in keys
        client.del k
      cb(err, true)

  ###
  Forcefully saves the given userinfo object.
  
  @param {Object} userinfo The user's info hash
  @param {Function} cb The callback function
  ###
  @save: (userinfo, cb) =>
    client.hmset User.key(userinfo.name),
      "name", userinfo.name,
      "email", userinfo.email,
      "password", userinfo.password,
      "token", userinfo.token,
      "secret", userinfo.secret,
      (err, hupdated) =>
        client.sadd User.key(), userinfo.name
        , (err, supdated) => cb(err, hupdated == 'OK')

  ###
  Logs in the given user.
  
  @param {String} username The user to log in
  @param {String} password The user password
  @param {Function} cb The callback function
  ###
  @login: (username, password, cb) =>
    User.find username, (err, userinfo) ->
      bcrypt.compare password, userinfo.password, cb

  ###
  Renames a current user.
  
  @param {String} target The origin username
  @param {String} destination What the origin will be renamed to
  @param {Function} cb The callback function    
  ###
  @rename: (target, destination, cb) ->
    User.exists target, (err, exists) ->
      if exists == true
        User.find target, (err, userinfo) ->
          User.exists destination, (err, exists2) ->
            if exists2 == true
              return cb("Cannot rename destination user exists: #{destination}", false)
            else
              userinfo.name = destination
              User.save userinfo, (err, success) ->
                user = new User(target)
                user.delete cb
      else
        return cb("Cannot rename target does not exist: #{target}", false)

  ###
  Creates a new user and adds them to the set of users.
  
  @param {String} email The users email address
  @param {String} password The users password
  @param {Function} cb The callback function
  ###
  create: (email, password, cb) =>
    keypair = generate_keypair()
    bcrypt.hash password, 10, (err, hash) =>
      userinfo = {}
      userinfo.name = @username
      userinfo.email = email
      userinfo.password = hash
      userinfo.token = keypair.token
      userinfo.secret = keypair.shared_secret
      User.save(userinfo, cb)

  ###
  Updates a user's email address.
  
  @param {String} email The user's email address
  @param {Function} cb The callback function
  ###
  update_email: (email, cb) =>
    User.find @username, (err, userinfo) ->
      userinfo.email = email
      User.save(userinfo, cb)
      
  ###
  Updates a user's password.
  
  @param {String} password The user's password
  @param {Function} cb The callback function
  ###
  update_password: (password, cb) =>
    User.find @username, (err, userinfo) ->
      bcrypt.hash password, 10, (err, hash) =>
        userinfo.password = hash
        User.save(userinfo, cb)
  
  ###
  Updates a user's token and secret.
  
  @param {Function} cb The callback function
  ###
  regenerate_tokens: (cb) =>
    User.find @username, (err, userinfo) ->
      keypair = generate_keypair()
      userinfo.token = keypair.token
      userinfo.secret = keypair.shared_secret
      User.save(userinfo, cb)
  
  ###
  Deletes a user and their information.
  
  @param {Function} cb The callback function
  ###
  delete: (cb) =>
    client.del User.key(@username), (err, success) =>
      client.srem User.key(), @username, cb

module.exports = User
