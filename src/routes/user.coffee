User = require '../models/user'

# Returns the list of users.
exports.list = (req, res, next) ->
  User.list (err, members) ->
    if err != null then logger.error err
    res.json 200,
      users: members

# Creates a new user.
exports.create = (req, res, next) ->
  user = new User(req.params['name'])
  user.create (err, is_member) ->
    if err != null then logger.error err
    res.json 200,
      is_member: is_member
