@['welcome#index'] = (data) ->
  if data.token and data.token.name == 'invite'
    ModalActions = require('actions/modal_actions')
    RegisterForm = cc.require('react/modals/register-form')

    params = {}
    params['invite'] = data.token.rfc1751
    if data.token.data
      params['full_name'] = data.token.data.full_name
      params['email'] = data.token.data.email

    ModalActions.show RegisterForm(params)