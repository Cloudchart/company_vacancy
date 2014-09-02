cc.module('react/shared/letter-avatar')

# Company Invite
# 
@['company_invites#show'] = (data) ->
  # Avatar
  # 
  AvatarComponent = cc.require('cc.components.Avatar')
  container = document.querySelector('[data-react-mount-point="avatar"]')

  React.renderComponent(AvatarComponent(
    value: data.author_full_name
    avatarURL: data.author_avatar_url
  ), container)


  if modalMountPoint = document.querySelector('[data-modal-mount-point]')
    ModalComponent = cc.require('react/shared/modal')
    React.renderComponent(ModalComponent({}), modalMountPoint)

  # Login form
  #
  if (loginButton = document.querySelector('[data-behaviour="login-button"]')) and (LoginForm = cc.require('react/modals/login-form'))
    loginButton.addEventListener 'click', (event) ->
      event.preventDefault()
      
      event = new CustomEvent 'modal:push',
        detail:
          component: LoginForm({})

      window.dispatchEvent(event)

    # loginButton.click() if window.location.hash == '#login'

  # Register form
  #
  # if (inviteButton = document.querySelectorAll('[data-behaviour~="invite-button"]')) and (RegisterForm  = cc.require('react/modals/register-form'))
  #   _.each inviteButton, (root) ->

  #     root.addEventListener 'click', (event) ->
  #       event.preventDefault()
        
  #       event = new CustomEvent 'modal:push',
  #         detail:
  #           component: RegisterForm({})
          
  #       window.dispatchEvent(event)
