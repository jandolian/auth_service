redis = require 'redis'
client = redis.createClient()

logger = require '../src/logger'
User = require '../src/models/user'

describe 'User', ->
  username = 'rivenreaver'
  user_email = 'bob@aol.com'
  user_password = 'password1234'
  
  users_key = [config.get('redis_prefix'), 'users'].join('_')
  ukey = [users_key, username].join(':')
  user = null
  
  beforeEach (done) ->
    logger.clear()
    user = new User(username)
    done()

  afterEach (done) ->
    user = null
    client.keys "#{config.get('redis_prefix')}*", (err, resp) ->
      for r in resp
        client.del r
      done()
  
  it "should be able to create a new user", (done) ->
    user.create user_email, user_password, (err, updated) ->
      assert.ifError err
      client.hgetall ukey, (err, data) ->
        assert.ifError err
        data.name.should.equal username
        data.email.should.equal user_email
        data.password.length.should.equal 60
        client.sismember users_key, username, (err, ismember) ->
          assert.ifError err
          assert.equal(ismember, true)
          done()
  
  it "should set tokens on user creation", (done) ->
    user.create user_email, user_password, (err, updated) ->
      assert.ifError err
      client.hgetall ukey, (err, data) ->
        assert.ifError err
        assert.notEqual data.token, null
        assert.notEqual data.token, undefined
        assert.notEqual data.secret, null
        assert.notEqual data.secret, undefined
        data.token.length.should.equal 16
        data.secret.length.should.equal 40
        done()
  
  it "should be able to delete a user", (done) ->
    user.create user_email, user_password, (err, updated) ->
      assert.ifError err
      user.delete (err, success) ->
        assert.ifError err
        client.hgetall ukey, (err, data) ->
          assert.ifError err
          assert.equal data, null
          client.sismember users_key, username, (err, ismember) ->
            assert.ifError err
            assert.equal ismember, false
            done()

  it "should be able to update a users name"
  
  it "should be able to update a users email address"
  
  it "should be able to update a users password"
  
  it "should be able to update a users token/secret"
