if modalMountPoint = document.querySelector('[data-modal-mount-point]')
  ModalComponent = require('components/modal_window')
  React.renderComponent(ModalComponent(), modalMountPoint)


# Login form
#
if (LoginButton = document.querySelector('[data-behaviour~="login-button"]')) and (LoginForm = cc.require('react/modals/login-form'))
  LoginButton.addEventListener 'click', (event) ->
    event.preventDefault()
    
    event = new CustomEvent 'modal:push',
      detail:
        component: LoginForm({})

    window.dispatchEvent(event)

  LoginButton.click() if window.location.hash == '#login'


# Invite form
#
if (InviteButton = document.querySelector('[data-behaviour~="invite-button"]')) and (InviteForm = cc.require('react/modals/invite-form'))
  InviteButton.addEventListener 'click', (event) ->
    event.preventDefault()
    
    event = new CustomEvent 'modal:push',
      detail:
        component: InviteForm({})

    window.dispatchEvent(event)

  InviteButton.click() if window.location.hash == '#invite'


#
#
_.each document.querySelectorAll('[data-react-class]'), (node) ->

  # TODO figure out how to catch errors later

  # try
    if !!node.dataset.reactClass
      reactClass  = require(node.dataset.reactClass)
      reactProps  = JSON.parse(node.dataset.reactProps) if node.dataset.reactProps
    
      React.renderComponent(reactClass(reactProps), node)
    
  # catch
  #   _.noop
