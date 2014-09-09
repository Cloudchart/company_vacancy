##= require stores/Base

Base = cc.require('cc.stores.Base')

Dispatcher = require('dispatcher/dispatcher')


parseDate = (value) ->
  value = Date.parse(value) if _.isString(value)
  value = new Date(value)   if _.isNumber(value)
  value = null unless _.isDate(value)
  value


# Vacancy Store
#
class Store extends Base
  
  @displayName:       'VacancyStore'
  

  parse_created_at: parseDate
  parse_updated_at: parseDate


# Dispatch token
#  

Store.dispatchToken = Dispatcher.register (payload) ->
  action = payload.action
  
  switch action.type
    

    when 'vacancy:create'
      action.model.attr(action.attributes)
      Store.emitChange()


    when 'vacancy:update'
      action.model.attr(action.attributes)
      Store.emitChange()


    when 'vacancy:fetch:done'
      _.each action.json, (attributes) -> Store.add(new Store(attributes))
      Store.emitChange()
    

    when 'vacancy:create:done'
      Store.add action.model.attr(action.json)
      Store.emitChange()
    

    when 'vacancy:create:fail'
      Store.emitChange()
    
    
    when 'vacancy:update:done'
    #  model = Store.find(action.key)
    #  model.attr(action.json)
      Store.emitChange()
    
    
    when 'vacancy:update:fail'
    #  model = Store.find(action.key)
    #  model.attr(action.json)
      Store.emitChange()


# Exports
#
cc.module('cc.stores.VacancyStore').exports = Store
