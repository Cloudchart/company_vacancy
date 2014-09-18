cc.module('react/shared/letter-avatar')

SignUpForm = cc.require('react/modals/register-form')
SignUpButton = document.querySelector('[data-behaviour="signup-button"]')

# Company Invite
# 
@['companies/invites#show'] = (data) ->
  # Avatar
  # 
  AvatarComponent = cc.require('cc.components.Avatar')
  container = document.querySelector('[data-react-mount-point="avatar"]')

  React.renderComponent(AvatarComponent(
    value: data.author_full_name
    avatarURL: data.author_avatar_url
  ), container)

  # if modalMountPoint = document.querySelector('[data-modal-mount-point]')
  #   ModalComponent = cc.require('react/shared/modal')
  #   React.renderComponent(ModalComponent({}), modalMountPoint)

  # Login form
  #
  if (loginButton = document.querySelector('[data-behaviour="invite-login-button"]')) and (LoginForm = cc.require('react/modals/login-form'))
    loginButton.addEventListener 'click', (event) ->
      event.preventDefault()

      event = new CustomEvent 'modal:push',
        detail:
          component: LoginForm({
            email: data.token.data.email
            invite: data.token.rfc1751
          })

      window.dispatchEvent(event)


  # Signup form
  # 
  SignUpButton.addEventListener 'click', (event) ->
    event.preventDefault()

    event = new CustomEvent 'modal:push',
      detail:
        component: SignUpForm({
          full_name: data.token.data.full_name
          email: data.token.data.email
          invite: data.token.rfc1751
        })

    window.dispatchEvent(event)
