# Node
#
Node = require('cloud_relay/node')


# User
#
class Pinboard extends Node


  @connection 'user', 'cloud_relay/nodes/user_node'


# Exports
#
module.exports = Pinboard
