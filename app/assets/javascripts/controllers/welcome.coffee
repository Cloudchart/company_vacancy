@['welcome#index_'] = (data) ->
  
  # Components
  #
  PasswordResetComponent = cc.require('react/modals/password-reset-form')
  RegisterForm = cc.require('react/modals/register-form')
  InviteForm = cc.require('react/modals/invite-form')
  RequestInviteForm = cc.require('react/modals/request-invite-form')

  InviteButton = document.querySelector('[data-behaviour~="invite-button"]')
  RequestInviteButton = document.querySelector('[data-behaviour~="request-invite-button"]')

  # Chart Preview
  # 
  cc.init_chart_preview()

  # Invite form
  #
  InviteButton.addEventListener 'click', (event) ->
    event.preventDefault()
    
    event = new CustomEvent 'modal:push',
      detail:
        component: InviteForm({})
      
    window.dispatchEvent(event)

  # Request invite form
  # 
  RequestInviteButton.addEventListener 'click', (event) ->
    event.preventDefault()
    
    event = new CustomEvent 'modal:push',
      detail:
        component: RequestInviteForm({})
      
    window.dispatchEvent(event)  


  # Token
  #
  if token = data.token
    
    component = switch token.name
    
      when 'invite'
        RegisterForm({ invite: token.rfc1751, email: token.data.email, full_name: token.data.full_name })
      
      when 'password'
        PasswordResetComponent({ token: token.uuid })
      
    
    if component
      event = new CustomEvent 'modal:push',
        detail:
          component: component
      window.dispatchEvent(event)


  # Password reset
  #
  #if data.password_reset_token and (PasswordResetForm = cc.require('react/modals/password-reset-form'))
  #  event = new CustomEvent 'modal:push',
  #    detail:
  #      component: PasswordResetForm({ token: data.password_reset_token })
    
  #  window.dispatchEvent(event)
