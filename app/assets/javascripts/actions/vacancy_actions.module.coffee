# Imports
#
Dispatcher      = require('dispatcher/dispatcher')
VacancySyncAPI  = require('utils/vacancy_sync_api')


# Main
#
Module =
  
  
  # Create
  #
  create: (model, attributes = {}) ->
    Dispatcher.handleClientAction
      type:       'vacancy:create'
      model:      model
      attributes: attributes

    VacancySyncAPI.create(model)
  
  
  # Update
  #
  update: (model, attributes = {}) ->
    Dispatcher.handleClientAction
      type:       'vacancy:update'
      model:      model
      attributes: attributes
    
    VacancySyncAPI.update(model)
    


# Exports
#
module.exports = Module