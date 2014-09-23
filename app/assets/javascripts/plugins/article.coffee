# @cc          ?= {}
# @cc.plugins  ?= {}

# $             = jQuery

# #
# #
# #


# for_each  = Array.prototype.forEach.call
# reduce    = Array.prototype.reduce.call
# index_of  = Array.prototype.indexOf.call


# # Create anchor
# create_anchor = ->
#   el            = document.createElement('div')
#   el.className  = 'droppable-anchor'
#   el


# # Generate anchors
# generate_anchors = (element) ->
#   sections = element.querySelectorAll('section')
  
#   for_each sections, (section) ->
#     section.appendChild(create_anchor())
    
#     blocks = sections.querySelectorAll('.identity-block')
    
#     for_each blocks, (block) ->
#       block.parentNode.insertBefore(block, create_anchor())


# # Clear anchors
# clear_anchors = (element) ->
#   for_each element.querySelectorAll('.droppable-anchor'), (anchor) -> anchor.parentNode.removeChild(anchor)


# # Closest anchor
# #
# closest_anchor = (element, event) ->
#   y = event.pageY - window.pageYOffset
  
#   data = reduce element.querySelectorAll('.droppable-anchor'), (memo, anchor) ->
#     bounds = anchor.getBoundingClientRect()
    
#     if memo == null or Math.abs(bounds.top - y) < Math.abs(memo.bounds.bottom - y)
#       memo =
#         element:  anchor
#         bounds:   bounds
#     memo
#   , null
  
#   data.element
  

# #
# #
# #  

# started = false

# widget = ->
#   return if started ; started = true
  
  
#   current_anchor = null
  

#   # On drag enter
#   #
#   on_enter = (event) ->
#     current_anchor = null
#     generate_anchors()
    

#   # On drag leave
#   #
#   on_leave = (event) ->
#     clear_anchors()
#     current_anchor = null
  

#   # On drag move
#   #
#   on_move = (event) ->
#     current_anchor = closest_anchor(@, event)


#   # On drag drop
#   #
#   on_drop = (event) ->
  
  
#   # Activate droppable
#   cc.ui.droppable()
  
#   #
#   # Observe events
#   #
  
#   $('article').on 'cc::drag:drop:enter', on_enter
  
#   $('article').on 'cc::drag:drop:leave', on_leave
  
#   $('article').on 'cc::drag:drop:move', on_move
  
#   $('article').on 'cc::drag:drop:drop', on_drop
  
  
#   # 
#   #
#   null


# #
# #
# #

# @cc.plugins.article = widget
