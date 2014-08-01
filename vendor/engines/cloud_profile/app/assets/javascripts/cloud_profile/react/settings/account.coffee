#
#
tag = cc.require('react/dom')

email_re = /(.)@(.)/ # aka hairy chest regex

EmailComponent = React.createClass
  
  render: ->

    (tag.li {},
      @props.address
    )

NewEmailComponent = React.createClass

  render: ->

    (tag.li {},
      (tag.button {
        disabled: !@isEmailValid() or @state.sync
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
      })

    )

  getInitialState: ->
    address: ''
    sync: false

  onKeyUp: (event) ->
    switch event.key

      when 'Escape'
        console.log 'Escape'
        # @props.onCancel() if @props.onCancel instanceof Function

      when 'Enter'
        console.log 'Enter'
        # @onVerifyButtonClick()

  onChange: (event) ->
    @setState({ address: event.target.value })

  isEmailValid: ->
    email_re.test(@state.address)        


Component = React.createClass

  render: ->

    (tag.div {
        className: 'content'
      },

      (tag.ul {},
        @state.emails.map (email_props) =>
          EmailComponent
            key: email_props.uuid
            address: email_props.address
            readOnly: @props.readOnly

        (NewEmailComponent {}) if @state.adding
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
    readOnly: true

  getInitialState: ->
    emails: @props.emails
    adding: false

  onAddButtonClick: (event) ->
    @setState({ adding: true })    

#
#
cc.module('profile/react/settings/account').exports = Component
