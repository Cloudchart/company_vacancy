##= require stores/PersonStore
##= require actions/server/person_server_actions.module

# Imports
#
PersonStore = cc.require('cc.stores.PersonStore')

PersonServerActions = require('actions/server/person_server_actions')


# Promises
#
promises = {}  


# Module
#
Module =
  
  
  #
  #
  fetch: (url) ->
    Promise.resolve(
      $.ajax
        url:        url
        type:       'GET'
        dataType:   'json'
    ).then(PersonServerActions.fetchDone, PersonServerActions.fetchFail)
  
  
  #
  #
  create: (company, model) ->
    Promise.resolve(
      $.ajax
        url:        "/companies/#{company}/people"
        type:       "POST"
        dataType:   "json"
        data:
          person:   model.attr()
    ).then(PersonServerActions.createDone.bind(null, model), PersonServerActions.createFail.bind(null, model))
  

  #
  #
  update: (key) ->
    Promise.resolve(
      $.ajax
        url:        "/people/#{key}"
        type:       "PUT"
        dataType:   "JSON"
        data:
          person:   PersonStore.find(key).attr()
    ).then(PersonServerActions.updateDone, PersonServerActions.updateFail)
  
  
# Exports
#
module.exports = Module
