crypto = require 'crypto'

###
Generates a new hexstring.

@param {Integer} (length) The length of the hex bytestring
@return {String} The randombyte hex string
###
generate_hex = (length=8) ->
  crypto.randomBytes(length).toString('hex')

generate_keypair = () ->
  { token: generate_hex(), shared_secret: generate_hex(20) }

module.exports =
  generate_hex: generate_hex
  identity: generate_hex()
  generate_keypair: generate_keypair
