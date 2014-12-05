Constants     = require("constants")
Dispatcher    = require("dispatcher/dispatcher")
EventEmitter  = require("utils/event_emitter")

__data = {}

Store =
  update: (key, data) ->
    __data[key] = data
    @emit("#{key}_changed")

  get: (key) ->
    __data[key]

_.extend Store, EventEmitter; Store.GetElementForEmitter()

actions = {}

actions[Constants.Company.FETCH_ACCESS_RIGHTS_DONE] = (key, json) ->
  Store.update("invitable_roles", json.invitable_roles)
  Store.update("invitable_contacts", json.invitable_contacts)

Store.dispatchToken = Dispatcher.register (payload) ->
  if _.has(actions, payload.action.type)
    actions[payload.action.type].apply(null, payload.action.data)

module.exports = Store