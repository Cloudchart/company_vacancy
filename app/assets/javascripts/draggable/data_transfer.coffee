###
  Used in:

  ui/draggable
  cloud_blueprint/plugins/mouse_draggable
###

@cc    ?= {}
@cc.ui ?= {}

#
#
#

widget = ->
  
  data        = {}
  dragImage   = null
  dragImageX  = 0
  dragImageY  = 0
  
  self  =

    setData: (type, value) ->
      data[type] = value

    getData: (type) ->
      data[type]
    
    clearData: (type = null) ->
      if type == null then data = {} else delete data[type]
      null
    
    setDragImage: (element, x = 0, y = 0) ->
      dragImage   = element
      dragImageX  = x
      dragImageY  = y
      
    
  # Set types accessor
  Object.defineProperty self, 'types', { get: -> Object.keys(data) }
  
  # Set drag image accessor
  Object.defineProperty self, 'dragImage', { get: -> { element: dragImage, x: dragImageX, y: dragImageY } }
  
  self
  

#
#
#

$.extend cc.ui,
  drag_drop_data_transfer: widget
