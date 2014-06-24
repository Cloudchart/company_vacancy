modal = 
  show: (content, options = {}) ->
    Arbiter.publish 'cc:blueprint:modal/show', _.extend({}, options, { content: content })

  hide: (force = false) ->
    Arbiter.publish 'cc:blueprint:modal/hide', { force: force }


#
#
#

_.extend @cc.blueprint.react,
  modal: modal

#
# Escape
#

$ ->
  
  $(window).on 'keyup', (event) ->
    return unless event.keyCode == 27
    modal.hide(true)
