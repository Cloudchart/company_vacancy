# On enter
#
on_enter = (event) ->  
  

# On leave
#
on_leave = (event) ->
  event.dataTransfer.setData('captured', false)


# On move
#
on_move = (event) ->
  event.dataTransfer.setData('captured', true) if event.dataTransfer.getData('identity')


# On drop
#
on_drop = (event) ->
  customEvent = new CustomEvent('drop:identity', {
    detail: {
      identity: event.dataTransfer.getData('identity')
      pageX:    event.pageX
      pageY:    event.pageY
    }
  })
  event.target.dispatchEvent(customEvent)
  


observer = (container) ->
  
  $container = $(container)
  
  $container.on 'cc::drag:drop:enter', on_enter
  $container.on 'cc::drag:drop:leave', on_leave
  $container.on 'cc::drag:drop:move',  on_move
  $container.on 'cc::drag:drop:drop',  on_drop

#
#
#

_.extend cc.blueprint.common,
  chart_droppable: observer
