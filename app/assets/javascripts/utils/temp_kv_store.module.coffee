
EventEmitter  = require("utils/event_emitter")
Constants   = require('constants')

__data = {}

Store =
  update: (key, data) ->
    __data[key] = data
    @emit("#{key}_changed")

  get: (key) ->
    __data[key]

_.extend Store, EventEmitter; Store.GetElementForEmitter()

module.exports = Store