# Imports
#
Dispatcher      = require('dispatcher/dispatcher')
VacancySyncAPI  = require('sync/vacancy_sync_api')
VacancyStore    = require('stores/vacancy')


# Exports
#
module.exports =
  
  
  create: (key, attributes, token = 'create') ->
    Dispatcher.handleClientAction
      type: 'vacancy:create-'
      data: [key, attributes, token]
    
    done = (json) ->
      Dispatcher.handleServerAction
        type: 'vacancy:create:done-'
        data: [key, json, token]

    fail = (xhr) ->
      Dispatcher.handleServerAction
        type: 'vacancy:create:done-'
        data: [key, xhr.responseJSON, xhr, token]
    
    record = VacancyStore.get(key)
    
    VacancySyncAPI.create(record.company_id, attributes, done, fail)
