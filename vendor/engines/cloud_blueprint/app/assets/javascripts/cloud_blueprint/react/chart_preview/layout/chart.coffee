# Calculate bounds
#
calculateBounds = (descriptors) ->
  descriptors = Object.keys(descriptors).map (uuid) -> descriptors[uuid]

  top:      descriptors.reduce ((memo, descriptor) -> Math.min(memo, descriptor.y)), 0
  right:    descriptors.reduce ((memo, descriptor) -> Math.max(memo, descriptor.x)), 0
  bottom:   descriptors.reduce ((memo, descriptor) -> Math.max(memo, descriptor.y)), 0
  left:     descriptors.reduce ((memo, descriptor) -> Math.min(memo, descriptor.x)), 0


# Calculate levels
#
calculateLevels = (descriptors) ->
  prevLevelMaxHeight  = 0
  levelOffset         = 0
  

  # Calculate max level
  #
  maxLevel = Object.keys(descriptors).reduce (memo, uuid) ->
    Math.max(memo, descriptors[uuid].level)
  , 0
  

  # Shift levels
  #
  [1..maxLevel].forEach (level) ->
    levelDescriptors = Object.keys(descriptors).filter (uuid) -> descriptors[uuid].level == level

    levelMaxHeight = levelDescriptors.reduce (memo, uuid) ->
      Math.max(memo, descriptors[uuid].height)
    , 0
    
    levelOffset = levelOffset + levelMaxHeight / 2 + prevLevelMaxHeight / 2
    
    levelDescriptors.forEach (uuid) -> descriptors[uuid].y = levelOffset
    
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
  

  # Sort descriptor children
  #
  Object.keys(descriptors).forEach (uuid) ->
    descriptor          = descriptors[uuid]
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
  

  # Calculate bounds
  #
  bounds = calculateBounds(descriptors)
  
  
  bounds:     bounds
  positions:  Object.keys(descriptors).reduce (memo, uuid) ->
      descriptor = descriptors[uuid]
      memo[uuid] = 
        x:  descriptor.x
        y:  descriptor.y
      memo
    , {}


# Exports
#
cc.module('blueprint/react/chart-preview/layout/chart').exports = Layout