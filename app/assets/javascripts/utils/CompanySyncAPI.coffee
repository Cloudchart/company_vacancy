##= require ../stores/CompanyStore
##= require ../actions/CompanyActionsCreator

# Imports
#
CompanyStore = cc.require('cc.stores.CompanyStore')
CompanyActionsCreator = cc.require('cc.actions.CompanyActionsCreator')


# Module
#
Module =
  
  
  load: (id) ->
    CompanyActionsCreator.startSync(id)
    
    $.ajax
      url:      "/companies/#{id}"
      type:     'GET'
      dataType: 'json'

    .done (json) ->
      CompanyActionsCreator.receiveOne(json)

    .fail (xhr) ->
      throw new Error("Error loading company with id: #{id}")

    .always ->
      CompanyActionsCreator.stopSync(id)
    
    
  save: (id) ->
  
  
  destroy: (id) ->
    
  

# Exports
#
cc.module('cc.utils.CompanySyncAPI').exports = Module
