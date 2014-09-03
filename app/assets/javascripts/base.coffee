if modalMountPoint = document.querySelector('[data-modal-mount-point]')
  ModalComponent = cc.require('react/shared/modal')
  React.renderComponent(ModalComponent({}), modalMountPoint)

# Login form
#
if (loginButton = document.querySelector('[data-behaviour~="login-button"]')) and (LoginForm = cc.require('react/modals/login-form'))
  loginButton.addEventListener 'click', (event) ->
    event.preventDefault()
    
    event = new CustomEvent 'modal:push',
      detail:
        component: LoginForm({})

    window.dispatchEvent(event)

  loginButton.click() if window.location.hash == '#login'
