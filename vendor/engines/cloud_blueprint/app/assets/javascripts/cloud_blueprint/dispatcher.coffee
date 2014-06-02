callbacks = []

#
#
#

synchronized_at     = null

pull = ->
  _.invoke cc.blueprint.models.Chart.instances, 'pull'


push = ->
  _.invoke cc.blueprint.models.Chart.instances, 'push'


apply_callbacks = ->
  _.each callbacks, (callback) -> callback()
  callbacks = []


synchronize = ->
  $.when(pull()...).done ->
    apply_callbacks()
    $.when(push()...).done ->
      $.when(pull()...).done ->
        Arbiter.publish('blueprint:dispatcher/sync')
    

#
#
#


dispatcher =
  
  sync: ->
    Arbiter.publish('blueprint:dispatcher/sync')
  

  __sync: (callback) ->

    if _.isFunction(callback)
      callback()
      callbacks.push(callback)

    synchronize()
    



_.extend cc.blueprint,
  dispatcher: dispatcher
