# Imports
#

Dispatcher = cc.require('cc.Dispatcher')


# Creator
#
Creator =
  

  receiveAll: (charts) ->
    charts = [charts] unless _.isArray(charts)

    Dispatcher.handleServerAction
      type: 'chart:receive:all'
      data: charts
  

  receiveOne: (chart) ->
    Dispatcher.handleServerAction
      type: 'chart:receive:one'
      data: chart
  

  update: (id, attributes = {}, shouldSave = false) ->
    Dispatcher.handleClientAction
      type: 'chart:update'
      data:
        id:         id
        attributes: attributes
        shouldSave: shouldSave
  
  
# Exports
#
cc.module('cc.blueprint.actions.ChartActionsCreator').exports = Creator
