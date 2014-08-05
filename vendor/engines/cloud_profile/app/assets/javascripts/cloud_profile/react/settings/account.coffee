#
#
tag = cc.require('react/dom')

# email_re = /(.)@(.)/ # aka hairy chest regex
email_re = /.+@.+\..+/i # like in CloudProfile::Email

# 
# 
CancelLinkComponent = React.createClass

  render: ->
    (tag.a {
      onClick: @onClick
      className: 'delete-link'
      href: ''
    },
      (tag.i { className: 'fa fa-times' })
    )

  getDefaultProps: ->
    disabled: false

  onClick: (event) ->
    event.preventDefault()
    @props.onDelete() unless @props.disabled

# 
# 
VerificationTokenComponent = React.createClass
  
  render: ->
    (tag.li {},

      (tag.button {
        onClick: @onResendButtonClick
        disabled: @state.sync
        className: 'orgpad resend'
      },
        (tag.ul {},
          (tag.li {}, 'Resend')
          (tag.li {}, (tag.i { className: 'fa fa-envelope-o' }))
        )
      )

      (tag.div { className: 'address grey' }, @props.address)

      (CancelLinkComponent {
        onDelete: @onDeleteClick  
        disabled: @state.sync
      })

    )

  getInitialState: ->
    sync: false

  onDeleteClick: (event) ->
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

      (tag.button {
        onClick: @onDeleteClick
        disabled: @state.sync
        className: 'orgpad alert'
      },
        (tag.ul {},
          (tag.li {}, 'Delete')
          (tag.li {}, (tag.i { className: 'fa fa-eraser' }))
        )
      ) unless @props.length == 1

      (tag.div { className: 'address green' }, @props.address)

    )

  getInitialState: ->
    sync: false

  onDeleteClick: (event) ->
    event.preventDefault()
    confirm('Are you sure?')
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
        className: 'orgpad verify'
      },
        (tag.ul {},
          (tag.li {}, 'Verify')
          (tag.li {}, (tag.i { className: 'fa fa-envelope-o' }))
        )
      )

      (tag.input {
        type: 'email'
        name: 'address'
        value: @state.address
        className: 'error' if @state.error
        disabled: @state.sync
        autoComplete: 'off'
        autoFocus: true
        onKeyUp: @onKeyUp
        onChange: @onChange
        onBlur: @onBlur
        onFocus: @onFocus
      })

      (CancelLinkComponent {
        onDelete: @onDeleteClick
      })

    )

  getInitialState: ->
    address: ''
    sync: false
    error: false

  onKeyUp: (event) ->
    switch event.key

      when 'Escape'
        @props.onCancel() # if @props.onCancel instanceof Function

      when 'Enter'
        @onVerifyButtonClick()

  onChange: (event) ->
    @setState({ address: event.target.value })

  onFocus: (event) ->
    @setState({ error: false })
  
  onBlur: (event) ->
    @props.onCancel() if @state.address.length == 0

  onDeleteClick:(event) ->
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
    # console.log json
    @setState({ sync: false })
    @props.onCreate({ target: { value: json.verification_tokens } })

  onCreateFail: (json) ->
    # console.log json
    @setState({ sync: false, error: true })
# 
# 
Component = React.createClass

  render: ->

    (tag.div {
        className: 'content'
      },

      (tag.ul {
        className: 'emails'  
      },
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
        className: 'orgpad add'
      },
        (tag.ul {},
          (tag.li {}, 'Add')
          (tag.li {}, (tag.i { className: 'fa fa-plus' }))
        )
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
        length: @state.emails.length
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
