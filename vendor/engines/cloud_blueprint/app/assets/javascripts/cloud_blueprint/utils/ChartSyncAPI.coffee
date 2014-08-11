##= require ../actions/ChartActionsCreator

# Imports
#

ChartActionsCreator   = cc.require('cc.blueprint.actions.ChartActionsCreator')


# Module
#
Module = 
  
  save: (item) ->
    $.ajax
      url:        "/charts/#{item.uuid}"
      type:       "put"
      dataType:   "json"
      data:
        chart:    item

    .done (json) ->
      ChartActionsCreator.receiveOne(json)

    .fail (xhr) ->
      ChartActionsCreator.receiveOne(xhr.responseJSON)
    
  
  
# Exports
#
cc.module('cc.blueprint.utils.ChartSyncAPI').exports = Module
