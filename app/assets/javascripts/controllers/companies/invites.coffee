cc.module('react/shared/letter-avatar')

LoginForm = cc.require('react/modals/login-form')
SignUpForm = cc.require('react/modals/register-form')
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


  # Login form
  #
  if loginButton = document.querySelector('[data-behaviour="invite-login-button"]')
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
  if SignUpButton = document.querySelector('[data-behaviour="signup-button"]')
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