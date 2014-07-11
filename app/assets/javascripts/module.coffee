@cc         ||= {}
modules       = {}


# Traverse path
#
traverse = (path) ->
  path.split('/').reduce(((memo, part) -> memo[part] ||= {} ; memo[part]), modules)


# cc.module('a/b/c').exports = Object
#
cc.module = (path) -> traverse(path)


# Object = cc.require('a/b/c')
#
cc.require = (path) -> traverse(path).exports
