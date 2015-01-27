# @cjsx React.DOM

RegisterForm = require('components/auth/register_form')

email_re = /.+@.+\..+/i

Errors =
  email:
    missing: "Enter email, please"
    invalid: "There are no users with such an email"
  full_name:
    missing: "Enter full name, please"
  password:
    missing: "Enter password, please"

getErrorMessages = (errorsLists) ->
  errors = _.mapValues errorsLists, (errors, attributeName) ->
    _.map errors, (errorName) ->
      Errors[attributeName][errorName]

  errors

validate = (attributes) ->
  errors =
    email:     []
    password:  []
    full_name: [] 

  if (!attributes.email || attributes.email == '')
    errors.email.push 'missing'
  else if (!email_re.test(attributes.email))
    errors.email.push 'invalid'

  if (!attributes.full_name || attributes.full_name == '')
    errors.full_name.push 'missing'

  if (!attributes.password || attributes.password == '')
    errors.password.push 'missing'

  errors


RegisterController = React.createClass

  # Component Specifications
  # 
  propTypes:
    attributes: React.PropTypes.object
    invite:     React.PropTypes.string

  getDefaultProps: ->
    attributes: {}
    invite:     ''

  getInitialState: ->
    attributes: @props.attributes || {}
    errors:     {}
    invite:     @props.invite || ''
    sync:       false

  # Helpers
  #
  isEmailAndNameValid: ->
    email_re.test(@state.email) and @state.full_name.length > 0
  
  isValidForRegister: ->
    @isEmailAndNameValid() and @state.password.length > 0 and @props.invite.length > 0

  onRegisterDone: (json) ->
    @setState({ sync: false })

    if json.state == 'login'
      window.location.reload()
    
    if json.state == 'activation'
      event = new CustomEvent 'modal:push',
        detail:
          component: SplashComponent({
            header: 'Activation'
            note: 'We have sent an activation email.'
          })
      
      window.dispatchEvent(event)
  
  onRegisterFail: (xhr) ->
    @setState({ sync: false })

    errors = xhr.responseJSON.errors
    errors.splice(errors.indexOf('emails'), 1, 'email') if errors.indexOf('emails') > - 1
    @setState
      errors: errors
  
  onRegisterButtonClick: (event) ->
    errors = validate(@state.attributes)

    if _.all(_.values(errors), (error) -> error.length == 0)
      @setState({ sync: true })

      $.ajax
        url:      '/register'
        type:     'POST'
        dataType: 'json'
        data:
          user:
            email:                  @state.attributes.email
            full_name:              @state.attributes.full_name
            password:               @state.attributes.password
            password_confirmation:  @state.attributes.password
            invite:                 @props.attributes.invite
      .done @onRegisterDone
      .fail @onRegisterFail
    else
      @setState(errors: errors)


  handleInputChange: (name, value) ->
    attributes = @state.attributes
    attributes[name] = value
    errors = @state.errors
    errors[name] = []

    @setState
      attributes: attributes
      errrors:    errors

  render: ->
    <RegisterForm
      attributes   = { @state.attributes }
      errors       = { getErrorMessages(@state.errors) }
      onChange     = { @handleInputChange }
      onSubmit     = { @onRegisterButtonClick }
      isDisabled   = { @state.sync } />

module.exports = RegisterController