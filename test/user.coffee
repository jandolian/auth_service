logger = require '../src/logger'
User = require '../src/models/user'

describe 'User', ->
  username = 'rivenreaver'
  user_email = 'bob@aol.com'
  user_password = 'password1234'
  user = null
  
  beforeEach (done) ->
    logger.clear()
    user = new User(username)
    done()

  afterEach (done) ->
    user = null
    User.delete_all (err, success) ->
      done()
  
  it "should be able to create a new user", (done) ->
    user.create user_email, user_password, (err, updated) ->
      assert.ifError err
      User.find username, (err, data) ->
        assert.ifError err
        data.name.should.equal username
        data.email.should.equal user_email
        data.password.length.should.equal 60
        User.exists username, (err, ismember) ->
          assert.ifError err
          assert.equal(ismember, true)
          done()
  
  it "should set tokens on user creation", (done) ->
    user.create user_email, user_password, (err, updated) ->
      assert.ifError err
      User.find username, (err, data) ->
        assert.ifError err
        assert.notEqual data.token, null
        assert.notEqual data.token, undefined
        assert.notEqual data.secret, null
        assert.notEqual data.secret, undefined
        data.token.length.should.equal 16
        data.secret.length.should.equal 40
        done()
  
  it "should be able to find a user", (done) ->
    user.create user_email, user_password, (err, updated) ->
      assert.ifError err
      User.find username, (err, userinfo) ->
        assert.ifError err
        userinfo.name.should.equal username
        userinfo.email.should.equal user_email
        userinfo.password.length.should.equal 60
        assert.notEqual userinfo.token, null
        assert.notEqual userinfo.token, undefined
        assert.notEqual userinfo.secret, null
        assert.notEqual userinfo.secret, undefined
        userinfo.token.length.should.equal 16
        userinfo.secret.length.should.equal 40
        done()
        
  it "should be able to verify if a user exists", (done) ->
    user.create user_email, user_password, (err, updated) ->
      assert.ifError err
      User.exists username, (err, exists) ->
        assert.ifError err
        assert.equal(exists, true)
        done()
  
  it "should be able to delete a user", (done) ->
    user.create user_email, user_password, (err, updated) ->
      assert.ifError err
      user.delete (err, success) ->
        assert.ifError err
        User.find username, (err, data) ->
          assert.ifError err
          assert.equal data, null
          User.exists username, (err, ismember) ->
            assert.ifError err
            assert.equal(ismember, false)
            done()

  it "should be able to delete all users", (done) ->
    user.create user_email, user_password, (err, updated) ->
      assert.ifError err
      username2 = "bob"
      user2 = new User(username2)
      user2.create user_email, user_password, (err, updated) ->
        assert.ifError err
        User.delete_all (err, success) ->
          assert.ifError err
          User.find username, (err, data) ->
            assert.ifError err
            assert.equal data, null
            User.find username2, (err, data) ->
              assert.ifError err
              assert.equal data, null
              done()
  
  it "should be able to update a user's name", (done) ->
    user.create user_email, user_password, (err, updated) ->
      assert.ifError err
      User.find username, (err, userinfo) ->
        assert.ifError err
        assert.notEqual userinfo, null
        User.rename username, "catdog123", (err, success) ->
          assert.ifError err
          assert.equal success, true
          User.find "catdog123", (err, ruserinfo) ->
            assert.ifError err
            assert.notEqual ruserinfo, null
            assert.equal ruserinfo.name, "catdog123"
            assert.equal ruserinfo.email, userinfo.email
            assert.equal ruserinfo.password, userinfo.password
            assert.equal ruserinfo.token, userinfo.token
            assert.equal ruserinfo.secret, userinfo.secret
            User.exists username, (err, exists) ->
              assert.ifError err
              assert.equal exists, false
              done()
  
  it "should be able to update a user's email address", (done) ->
    user.create user_email, user_password, (err, updated) ->
      assert.ifError err
      user.update_email "coolmail@gmail.com", (err, success) ->
        assert.ifError err
        User.find username, (err, userinfo) ->
          assert.ifError err
          assert.notEqual userinfo, null
          assert.equal userinfo.email, "coolmail@gmail.com"
          done()
        
  it "should be able to update a user's password", (done) ->
    user.create user_email, user_password, (err, updated) ->
      assert.ifError err
      user.update_password "catdog2333", (err, success) ->
        assert.ifError err
        assert.equal success, true
        User.login username, "catdog2333", (err, success) ->
          assert.ifError err
          assert.equal success, true
          done()
  
  it "should be able to update a user's token/secret", (done) ->
    user.create user_email, user_password, (err, updated) ->
      assert.ifError err
      user.regenerate_tokens (err, data) ->
        assert.ifError err
        User.find username, (err, userinfo) ->
          assert.ifError err
          assert.notEqual userinfo.token, null
          assert.notEqual userinfo.token, undefined
          assert.notEqual userinfo.secret, null
          assert.notEqual userinfo.secret, undefined
          userinfo.token.length.should.equal 16
          userinfo.secret.length.should.equal 40
          done()
      
        