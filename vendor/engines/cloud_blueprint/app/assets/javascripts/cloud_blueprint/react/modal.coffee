###
  Used in:

  cloud_blueprint/actions/modal_window_actions_creator
  cloud_blueprint/react/blueprint
  cloud_blueprint/react/blueprint/chart
  cloud_blueprint/react/blueprint/node
  cloud_blueprint/react/forms/identity_form
  cloud_blueprint/react/forms/identity_form_commons
  cloud_blueprint/react/forms/node_form
  cloud_blueprint/react/forms/node_form_identities
  cloud_blueprint/react/identity/identity
  cloud_blueprint/react/identity_filter/buttons
  cloud_blueprint/react/identity_filter/identity_list
###

modal = 
  show: (content, options = {}) ->
    Arbiter.publish 'cc:blueprint:modal/show', _.extend({}, options, { content: content })

  hide: (force = false) ->
    Arbiter.publish 'cc:blueprint:modal/hide', { force: force }


modal.open    = modal.show
modal.close   = modal.hide


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
