@cc    ?= {}
@cc.ui ?= {}

#
#
#

widget = ->
  
  data  = {}
  
  self  =

    setData: (type, value) ->
      data[type] = value

    getData: (type) ->
      data[type]
    
    clearData: (type = null) ->
      if type == null then data = {} else delete data[type]
      null
    
  # Set types accessor
  Object.defineProperty self, 'types', { get: -> Object.keys(data) }
  
  self
  

#
#
#

$.extend cc.ui,
  drag_drop_data_transfer: widget
