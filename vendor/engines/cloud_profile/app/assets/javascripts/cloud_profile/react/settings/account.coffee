#
#
tag = cc.require('react/dom')

email_re = /[^@]+@[^\.]{2,}\.[^\.]{2,}/


# Email Component
#
EmailComponent = React.createClass

  render: ->
    (tag.li {
      className: 'email'
    },

      (tag.button {},
        "Delete"
        (tag.i { className: 'fa fa-times' })
      ) unless @props.readOnly or @props.count == 1

      @props.address
    )


# Token Component
#
TokenComponent = React.createClass


  onDeleteDone: (json) ->
    @setState({ deleting: false })
    @props.onDelete({ target: { value: json.verification_tokens }}) if @props.onDelete instanceof Function
  
  
  onDeleteFail: (xhr) ->
    @setState({ deleting: false })


  onDeleteButtonClick: ->
    
    $.ajax
      url:      "/profile/emails/#{@props.key}"
      type:     "DELETE"
      dataType: "json"
    .done @onDeleteDone
    .fail @onDeleteFail
    
    @setState({ deleting: true })
  
  
  getInitialState: ->
    deleting: false


  render: ->
    (tag.li {
      className: 'token'
    },
      (tag.button {
        disabled: @state.deleting
      },
        "Verify"
        (tag.i { className: 'fa fa-envelope-o' })
      )
      @props.address

      (tag.button {
        onClick:  @onDeleteButtonClick
        disabled: @state.deleting
      },
        (tag.i { className: 'fa fa-times' }) unless @state.deleting
        (tag.i { className: 'fa fa-spinner fa-spin' }) if @state.deleting
      )
    )


# New Email Component
#
NewEmailComponent = React.createClass


  isEmailValid: ->
    email_re.test(@state.address)


  blur: ->
    @refs['input'].getDOMNode().blur()
  
  
  onCreateDone: (json) ->
    @setState
      synchronizing:  false
      error:          false
    
    @props.onCreate({ target: { value: json.verification_tokens }}) if @props.onCreate instanceof Function
  
  
  onCreateFail: ->
    @setState
      synchronizing:  false
      error:          true


  onVerifyButtonClick: (event) ->
    return unless @isEmailValid()

    
    $.ajax
      url:      '/profile/emails'
      type:     'POST'
      dataType: 'json'
      data:
        address:  @state.address
    .done @onCreateDone
    .fail @onCreateFail


    @blur()
    @setState({ synchronizing: true })


  onChange: (event) ->
    @setState({ address: event.target.value.trim() })
  
  
  onFocus: (event) ->
    @setState({ error: false })
  
  
  onBlur: (event) ->
    @props.onCancel() if @props.onCancel instanceof Function and @state.address.length == 0
  
  
  onKeyUp: (event) ->
    switch event.key

      when 'Escape'
        @props.onCancel() if @props.onCancel instanceof Function

      when 'Enter'
        @onVerifyButtonClick()
  
  
  getInitialState: ->
    address:        ''
    error:          false
    synchronizing:  false


  render: ->
    (tag.li {},
    
      (tag.button {
        onClick:    @onVerifyButtonClick
        disabled:  !@isEmailValid() or @state.synchronizing
      },
        "Verify"
        (tag.i { className: 'fa fa-envelope-o' }) unless @state.synchronizing
        (tag.i { className: 'fa fa-spinner fa-spin' }) if @state.synchronizing
      )
    
      (tag.input {
        ref:            'input'
        type:           'email'
        name:           'address'
        className:      'error' if @state.error
        autoComplete:   'off'
        disabled:       @state.synchronizing
        autoFocus:      true
        value:          @state.address
        onFocus:        @onFocus
        onBlur:         @onBlur
        onChange:       @onChange
        onKeyUp:        @onKeyUp
      })
    )



# Main Component
#
Component = React.createClass


  emailComponents: ->
    @state.emails.map (email_props) =>
      EmailComponent
        key:      email_props.uuid
        address:  email_props.address
        readOnly: @props.readOnly
        count:    @props.emails.length
  
  
  tokenComponents: ->
    @state.tokens.map (token_props) =>
      TokenComponent
        key:      token_props.uuid
        address:  token_props.data.address
        onDelete: @onTokenDelete
  
  
  onTokenDelete: (event) ->
    @setState({ tokens: event.target.value })
  
  
  onNewEmailCreate: (event) ->
    console.log 'create'
    @setState({ tokens: event.target.value, adding: false })
  
  
  onAddCancel: ->
    @setState({ adding: false })
  
  
  onAddButtonClick: (event) ->
    @setState({ adding: true })
  
  
  getDefaultProps: ->
    readOnly: true
  
  
  getInitialState: ->
    emails: @props.emails || []
    tokens: @props.tokens || []
    adding: false


  render: ->
    (tag.div {
      className: 'content'
    },
      (tag.ul {},
        @emailComponents()
        @tokenComponents()

        (NewEmailComponent {
          onCancel: @onAddCancel
          onCreate: @onNewEmailCreate
        }) if @state.adding

      )

      (tag.button {
        onClick: @onAddButtonClick
      },
        "Add"
        (tag.i { className: 'fa fa-check' })
      ) unless @props.readOnly or @state.adding
    )


#
#
cc.module('profile/react/settings/account').exports = Component