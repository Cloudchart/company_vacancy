@['welcome#index'] = (data) ->
  
  # Components
  #
  PasswordResetComponent = cc.require('react/modals/password-reset-form')

  # Chart Preview
  # 
  cc.init_chart_preview()

  # Register form
  #
  if (inviteButton = document.querySelectorAll('[data-behaviour~="invite-button"]')) and (RegisterForm  = cc.require('react/modals/register-form'))
    _.each inviteButton, (root) ->

      root.addEventListener 'click', (event) ->
        event.preventDefault()
        
        event = new CustomEvent 'modal:push',
          detail:
            component: RegisterForm({})
          
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
