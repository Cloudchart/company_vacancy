#
#
tag = cc.require('react/dom')

email_re = /(.)@(.)/ # aka hairy chest regex

# 
# 
VerificationTokenComponent = React.createClass
  
  render: ->
    (tag.li {},
      (tag.button {
        onClick: @onResendButtonClick
        disabled: @state.sync
      },
        'Resend'
        (tag.i { className: 'fa fa-envelope-o' })
      )

      @props.address

      (tag.a {
        href: ''
        onClick: @onDeleteClick
        disabled: @state.sync
      },
        (tag.i { className: 'fa fa-times' })
      )
    )

  getInitialState: ->
    sync: false

  onDeleteClick: (event) ->
    event.preventDefault()
    @setState({ sync: true })

    $.ajax
      url: @props.email_path
      method: 'DELETE'
      dataType: 'json'
    .done @onDeleteDone

  onDeleteDone: (json) ->
    @setState({ sync: false })
    @props.onDelete({ target: { value: json.verification_tokens } })

  onResendButtonClick: ->
    @setState({ sync: true })

    $.ajax
      url: @props.resend_verification_email_path
      method: 'PUT'
      dataType: 'json'
    .done @onResendVerificationDone

  onResendVerificationDone: (json) ->
    @setState({ sync: false })

# 
# 
EmailComponent = React.createClass
  
  render: ->

    (tag.li {},
      @props.address

      (tag.a {
        onClick: @onDeleteClick
        href: ''
      },
        (tag.i { className: 'fa fa-times' })
      ) unless @props.length == 1
    )

  getInitialState: ->
    sync: false

  onDeleteClick: (event) ->
    event.preventDefault()
    @setState({ sync: true })

    $.ajax
      url: @props.email_path
      method: 'DELETE'
      dataType: 'json'
    .done @onDeleteDone

  onDeleteDone: (json) ->
    @setState({ sync: false })
    @props.onDelete({ target: { value: json.emails } })

# 
# 
NewEmailComponent = React.createClass

  render: ->

    (tag.li {},
      (tag.button {
        disabled: !@isEmailValid() or @state.sync
        onClick: @onVerifyButtonClick
      },
        'Verify'
        (tag.i { className: 'fa fa-envelope-o' })
      )

      (tag.input {
        type: 'email'
        value: @state.address
        autoFocus: true
        onKeyUp: @onKeyUp
        onChange: @onChange
        disabled: @state.sync
        autoComplete: 'off'
      })

      (tag.a {
        onClick: @onDeleteClick
        href: ''
      },
        (tag.i { className: 'fa fa-times' })
      )

    )

  getInitialState: ->
    address: ''
    sync: false

  onKeyUp: (event) ->
    switch event.key

      when 'Escape'
        @props.onCancel() # if @props.onCancel instanceof Function

      when 'Enter'
        @onVerifyButtonClick()

  onChange: (event) ->
    @setState({ address: event.target.value })

  onDeleteClick:(event) ->
    event.preventDefault()
    @props.onCancel()

  isEmailValid: ->
    email_re.test(@state.address)        

  onVerifyButtonClick: ->
    return unless @isEmailValid()

    @setState({ sync: true })

    $.ajax
      url: @props.emails_path
      method: 'POST'
      dataType: 'json'
      data:
        address: @state.address
    .done @onCreateDone
    .fail @onCreateFail

  onCreateDone: (json) ->
    @setState({ sync: false })
    @props.onCreate({ target: { value: json.verification_tokens } })

  onCreateFail: ->
    console.log 'Fail'
# 
# 
Component = React.createClass

  render: ->

    (tag.div {
        className: 'content'
      },

      (tag.ul {},
        @emailComponents()
        @verificationTokenComponents()

        (NewEmailComponent {
          onCancel: @onNewEmailCancel
          onCreate: @onNewEmailCreate
          emails_path: @props.emails_path
        }) if @state.adding
      )

      (tag.button {
        onClick: @onAddButtonClick
      },
        'Add'
        (tag.i { className: 'fa fa-plus' })
      ) unless @props.readOnly or @state.adding
      
    )

  getDefaultProps: ->
    emails: []
    verification_tokens: []
    readOnly: true # what is it for?

  getInitialState: ->
    emails: @props.emails
    verification_tokens: @props.verification_tokens
    adding: false

  onAddButtonClick: (event) ->
    @setState({ adding: true })    

  emailComponents: ->
    @state.emails.map (email_props) =>
      EmailComponent
        key: email_props.uuid
        address: email_props.address
        readOnly: @props.readOnly
        length: @props.emails.length
        email_path: email_props.email_path
        onDelete: @onEmailDelete

  onEmailDelete: (event) ->
    @setState({ emails: event.target.value })

  onNewEmailCancel: ->
    @setState({ adding: false })

  onNewEmailCreate: (event) ->
    @setState({ 
      adding: false
      verification_tokens: event.target.value 
    })

  verificationTokenComponents: ->
    @state.verification_tokens.map (verification_token_props) =>
      VerificationTokenComponent
        key: verification_token_props.uuid
        address: verification_token_props.data.address
        email_path: verification_token_props.email_path
        resend_verification_email_path: verification_token_props.resend_verification_email_path
        onDelete: @onVerificationTokenDelete

  onVerificationTokenDelete: (event) ->
    @setState({ verification_tokens: event.target.value })

#
#
cc.module('profile/react/settings/account').exports = Component
