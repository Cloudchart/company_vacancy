# @cjsx React.DOM

SignupForm = require('components/auth/signup_form')

email_re = /.+@.+\..+/i

Errors =
  email:
    missing:  "Enter email, please"
    invalid:  "The email is entered in a wrong format"
  full_name:
    missing:  "Enter full name, please"
  password:
    missing:   "Enter password, please"

getErrorMessages = (errorsLists) ->
  errors = _.mapValues errorsLists, (errors, attributeName) ->
    _.map errors, (errorName) ->
      if Errors[attributeName]
        Errors[attributeName][errorName] || errorName

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
    email:      React.PropTypes.string
    invite:     React.PropTypes.string

  getDefaultProps: ->
    attributes: {}
    email:      ''
    invite:     ''

  getInitialState: ->
    attributes = @props.attributes || {}

    if @props.email != ''
      attributes.email = @props.email

    attributes: attributes
    errors:     {}
    invite:     @props.invite || ''
    isSyncing:  false


  # Helpers
  #
  isValid: (errors) ->
    _.all(_.values(errors), (error) -> error.length == 0)

  requestSignup: (event) ->
    if @isValid(@state.errors)
      errors = validate(@state.attributes)

      if @isValid(errors)
        @setState(isSyncing: true)

        $.ajax
          url:      '/signup'
          type:     'POST'
          dataType: 'json'
          data:
            user:
              email:                  @state.attributes.email
              full_name:              @state.attributes.full_name
              password:               @state.attributes.password
              password_confirmation:  @state.attributes.password
              invite:                 @props.invite
        .done @handleSignupDone
        .fail @handleSignupFail
      else
        @setState(errors: errors)


  # Handlers
  #
  handleSignupDone: (json) ->
    if json.state == 'login'
      window.location.href = json.previous_path
    
    if json.state == 'activation'
      @setState(isSyncing: false)

      event = new CustomEvent 'modal:push',
        detail:
          component: SplashComponent({
            header: 'Activation'
            note: 'We have sent an activation email.'
          })
      
      window.dispatchEvent(event)
  
  handleSignupFail: (xhr) ->
    @setState(isSyncing: false)

    @setState
      errors: _.pick(xhr.responseJSON.errors, ["email", "full_name", "password"])

  handleInputChange: (name, value) ->
    attributes = @state.attributes
    attributes[name] = value
    errors = @state.errors
    errors[name] = []

    @setState
      attributes: attributes
      errrors:    errors


  render: ->
    <SignupForm
      attributes   = { @state.attributes }
      errors       = { getErrorMessages(@state.errors) }
      isSyncing    = { @state.isSyncing }
      onChange     = { @handleInputChange }
      onSubmit     = { @requestSignup } />

module.exports = RegisterController