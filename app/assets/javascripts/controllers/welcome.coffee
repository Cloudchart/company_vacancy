@['welcome#index'] = (data) ->
  
  # Components
  #
  PasswordResetComponent = cc.require('react/modals/password-reset-form')


  if data.chart_id and chartPreviewMountPoint = document.querySelector('[data-react-chart-preview-mount-point]')
    ChartPreviewComponent = cc.require('blueprint/react/chart-preview')
  
    chartPreview = ChartPreviewComponent({ id: data.chart_id, scale: 1 })

    React.renderComponent(chartPreview, chartPreviewMountPoint)
  
  
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
