@['cloud_profile/users#activation_complete'] = (data) ->
  
  MainComponent   = cc.require('react/profile/activation/main')
  mountPoint      = document.querySelector('[data-react-root]')

  component       = MainComponent
    title:  'Welcome'
    note:   'Knowing your name would help us.'
    user:   data.user
  
  React.renderComponent(component, mountPoint)
