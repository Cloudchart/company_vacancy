# Node
#
Node = require('cloud_relay/node')


# User
#
class User extends Node


  @connection 'pinboards', 'cloud_relay/nodes/pinboard_node'


# Exports
#
module.exports = User
