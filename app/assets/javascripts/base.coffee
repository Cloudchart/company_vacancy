if modalMountPoint = document.querySelector('[data-modal-mount-point]')
  ModalComponent = cc.require('react/shared/modal')
  React.renderComponent(ModalComponent({}), modalMountPoint)

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
