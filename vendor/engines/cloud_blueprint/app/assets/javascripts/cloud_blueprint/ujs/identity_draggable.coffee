# Self
#

self = {}


# Clone element for drag
#

drag_image = (element) ->
  clone = element.cloneNode(true)
  document.body.appendChild(clone)
  
  bounds = element.getBoundingClientRect()

  clone.classList.add('identity-draggable')

  clone.style.position  = 'absolute'
  clone.style.width     = bounds.width + 'px'
  clone.style.height    = bounds.height + 'px'

  clone
  

# On drag start
#
on_start = (event) ->
  self        = {}
  self.clone  = drag_image(event.target)
  uuid        = event.target.dataset.id
  className   = event.target.dataset.className
  target_rect = event.target.getBoundingClientRect()
  
  event.dataTransfer.setData('identity', JSON.stringify({ className: className, uuid: uuid }))
  event.dataTransfer.setDragImage(self.clone, event.pageX - target_rect.left, event.pageY - target_rect.top)
  


# On drag end
#
on_end = (event) ->
  self.clone.parentNode.removeChild(self.clone) if self.clone
  self = {}

#
#
#

observer = (container, selector) ->
  $container = $(container)
  
  $container.on 'cc::drag:start', selector, on_start
  $container.on 'cc::drag:end',   selector, on_end

#
#
#

_.extend cc.blueprint.common,
  identity_draggable: observer
