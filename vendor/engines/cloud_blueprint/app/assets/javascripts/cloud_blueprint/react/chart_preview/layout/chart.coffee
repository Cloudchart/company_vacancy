# Calculate bounds
#
calculateBounds = (descriptors) ->
  bounds =
    top:      descriptors.reduce ((memo, descriptor) -> Math.min(memo, descriptor.y - descriptor.height / 2)), 0
    right:    descriptors.reduce ((memo, descriptor) -> Math.max(memo, descriptor.x + descriptor.width  / 2)), 0
    bottom:   descriptors.reduce ((memo, descriptor) -> Math.max(memo, descriptor.y + descriptor.height / 2)), 0
    left:     descriptors.reduce ((memo, descriptor) -> Math.min(memo, descriptor.x - descriptor.width  / 2)), 0
  
  bounds.width  = bounds.right  - bounds.left
  bounds.height = bounds.bottom - bounds.top
  
  bounds


# Calculate connections
#
calculateConnections = (descriptors) ->
  descriptors.forEach (descriptor) ->

    descriptor.connectFrom =
      x: descriptor.x
      y: descriptor.y - descriptor.height / 2
    
    return if descriptor.children.length == 0

    delta   = descriptor.width / (descriptor.children.length + 1)
    xOffset = descriptor.x - descriptor.width   / 2
    yOffset = descriptor.y + descriptor.height  / 2

    descriptor.children.forEach (child, i) ->
      child.connectTo =
        x: (i + 1) * delta + xOffset
        y: yOffset


# Calculate levels
#
calculateLevels = (descriptors) ->
  prevLevelMaxHeight  = 0
  levelOffset         = 0
  

  # Calculate max level
  #
  maxLevel = descriptors.reduce (memo, descriptor) ->
    Math.max(memo, descriptor.level)
  , 0
  

  # Shift levels
  #
  [1..maxLevel].forEach (level) ->
    levelDescriptors = descriptors.filter (descriptor) -> descriptor.level == level

    levelMaxHeight = levelDescriptors.reduce (memo, descriptor) ->
      Math.max(memo, descriptor.height)
    , 0
    
    levelOffset = levelOffset + levelMaxHeight / 2 + prevLevelMaxHeight / 2
    
    levelDescriptors.forEach (descriptor) -> descriptor.y = levelOffset
    
    prevLevelMaxHeight = levelMaxHeight
    
    levelOffset = levelOffset + 50



# Layout
#
Layout = (components) ->
  # Prepare root descriptor
  #
  root_descriptor =
    root:     true
    children: []
  

  # Prepare descriptors
  #
  descriptors = Object.keys(components).reduce (memo, uuid) ->
    component   = components[uuid]

    descriptor  =
      id:         component.getUUID()
      knots:      component.getKnots()
      parent_id:  component.getParentId()
      width:      component.getWidth()
      height:     component.getHeight()
      position:   component.getPosition()
      children:   []

    memo[uuid] = descriptor ; memo
  , {}
  

  # Connect descriptors
  #
  Object.keys(descriptors).forEach (uuid) ->
    descriptor        = descriptors[uuid]
    descriptor.parent = descriptors[descriptor.parent_id]
    descriptor.parent = root_descriptor unless descriptor.parent

    descriptor.parent.children.push(descriptor)
  

  # Unwrap descriptors
  #
  descriptors = Object.keys(descriptors).map (uuid) -> descriptors[uuid]
  

  # Sort descriptor children
  #
  descriptors.forEach (descriptor) ->
    children            = descriptor.children
    descriptor.children = descriptor.children.sort (a, b) -> a.position - b.position


  # Calculate tree layout
  #
  cc.blueprint.layouts.tree root_descriptor,
    h_distance: (prev, next) ->
      padding   = if prev.parent_id == next.parent_id then 20 else 50
      padding  += (prev.width + next.width) / 2
  

  # Calculate levels
  #
  calculateLevels(descriptors)
  

  # Calculate connections
  #
  calculateConnections(descriptors)
  
  
  # Calculate bounds
  #
  bounds = calculateBounds(descriptors)
  

  bounds:     bounds
  positions:  descriptors.reduce (memo, descriptor) ->
      memo[descriptor.id] = 
        x:            descriptor.x
        y:            descriptor.y
        connectFrom:  descriptor.connectFrom
        connectTo:    descriptor.connectTo
      memo
    , {}


# Exports
#
cc.module('blueprint/react/chart-preview/layout/chart').exports = Layout
