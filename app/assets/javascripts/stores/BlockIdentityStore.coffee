###
  Used in:

  actions/BlockIdentityActionsCreator
  editor/BlockIdentityController
  react_components/editor/blocks/people
###

##= require dispatcher/Dispatcher
##= require stores/Base
##= require stores/PersonStore
##= require stores/VacancyStore


Dispatcher    = cc.require('cc.Dispatcher')
Base          = cc.require('cc.stores.Base')
PersonStore   = cc.require('cc.stores.PersonStore')
VacancyStore  = cc.require('cc.stores.VacancyStore')

Stores =
  Person:   PersonStore
  Vacancy:  VacancyStore


parseDate = (value) ->
  value = Date.parse(value) if _.isString(value)
  value = new Date(value)   if _.isNumber(value)
  value = null unless _.isDate(value)
  value


# Vacancy Store
#
class Store extends Base
  
  @displayName:       'BlockIdentityStore'
  
  @allForBlock: (blockID) ->
    _.filter @all(), (model) -> model.attr('block_id') == blockID
  
  
  parse_created_at: parseDate
  parse_updated_at: parseDate
  

  parse_identity: (value) ->
    IdentityStore = Stores[@attr('identity_type')]
    IdentityModel = new IdentityStore(value)
    IdentityStore.add(IdentityModel)
    IdentityModel


# Dispatch Token
#
Store.dispatchToken = Dispatcher.register (payload) ->
  action = payload.action
  
  switch action.type

    when 'block/identity:receive:done'
      _.each action.data, (attributes) -> Store.add(new Store(attributes))
      Store.emitChange()
    

    when 'block/identity:receive:created'
      Store.add(action.data)
      Store.emitChange()


    when 'block/identity:create:done'
      action.data.model.attr(action.data.json)
      Store.emitChange()


    when 'block/identity:destroy', 'block/identity:destroy:done'
      Store.remove(action.data)
      Store.emitChange()


    when 'block/identity:destroy:fail'
      Store.add(action.data.model)
      Store.emitChange()


# Exports
#
cc.module('cc.stores.BlockIdentityStore').exports = Store
