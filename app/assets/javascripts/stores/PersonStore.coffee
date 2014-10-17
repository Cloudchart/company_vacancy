###
  Used in:

  actions/PersonActionsCreator
  components/Person
  components/company/progress
  components/editor/IdentitySelector
  stores/BlockIdentityStore
  stores/person_store
  stores/PersonStore
  utils/person_sync_api
  cloud_blueprint/components/person_form
  cloud_blueprint/models/person
  cloud_blueprint/react/identity/identity
  cloud_blueprint/react/identity_filter/buttons
###

##= require ./Base
##= require dispatcher/dispatcher.module

Base        = cc.require('cc.stores.Base')
Dispatcher  = require('dispatcher/dispatcher')


parseDate = (value) ->
  value = Date.parse(value) if _.isString(value)
  value = new Date(value)   if _.isNumber(value)
  value = null unless _.isDate(value)
  value


parseDecimals = (value) ->
  parseInt(value, 10) || null


# Person Store
#
class PersonStore extends Base
  
  @displayName:       'PersonStore'
  
  @attributesForSort:   ['last_name', 'first_name']
  @attributesForMatch:  ['last_name', 'first_name', 'occupation']
  

  parse_salary:     parseDecimals
  parse_birthday:   parseDate
  parse_hired_on:   parseDate
  parse_fired_on:   parseDate
  parse_created_at: parseDate
  parse_updated_at: parseDate
  

# Dispatch Token
#
PersonStore.dispatchToken = Dispatcher.register (payload) ->
  action = payload.action
  
  switch action.type
    
    # Fetch done
    #
    when 'person:fetch:done'
      _.each action.json, (attributes) -> PersonStore.add(new PersonStore(attributes))
      PersonStore.emitChange()
    
    
    # Create
    #
    when 'person:create'
      action.model.attr(action.attributes)
      PersonStore.emitChange()
    
    
    # Create done
    #
    when 'person:create:done'
      action.model.attr(action.json)
      PersonStore.add(action.model)
      PersonStore.emitChange()
    

    # Update
    #
    when 'person:update'
      model = PersonStore.find(action.key)
      
      throw new Error("#{PersonStore.displayName}: Object with key \"#{action.key}\" not found.") unless model
      
      model.attr(action.attributes)
      PersonStore.emitChange()
    

    # Update done
    #
    when 'person:update:done'
      PersonStore.add(new PersonStore(action.json))
      PersonStore.emitChange()
    

    # Update fail
    #
    when 'person:update:fail'
      attributes = action.xhr.responseJSON
      model = PersonStore.find(attributes[PersonStore.unique_key])
      model.attr(attributes)
      PersonStore.emitChange()
    

# Exports
#
cc.module('cc.stores.PersonStore').exports = PersonStore
